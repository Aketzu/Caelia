# frozen_string_literal: true

require 'net/http'

class Vod < ActiveRecord::Base
  belongs_to :recording

  def length
    return 0 unless end_pos && start_pos

    end_pos - start_pos
  end

  def make_ffcat
    File.open("#{recording.basepath}/#{recording.name}/vod.ffcat", File::WRONLY | File::TRUNC | File::CREAT) do |f|
      f.puts 'ffconcat version 1.0'
      recording.sourcefiles.sort.each do |sf|
        f.puts "file #{sf.filename}"
        f.puts "duration #{sf.length}"
      end
    end
  end

  def title_fn
    name.scan(/./).map { |ch| ch.gsub(/ /, '_').gsub(/[^A-Za-z0-9_]/, '') }.flatten.join('')
  end

  def vod_filepath
    return "#{recording.basepath}/#{elaineid}_#{title_fn}.mp4" if elaineid&.positive?

    "#{recording.basepath}/vod_#{id}_#{title_fn}.mp4"
  end

  def self.Statuses
    ['New', 'Prepare encode', 'Loudnorm', 'Encoding', 'Optimizing', 'VOD done', 'Uploading', "Tube'd"]
  end

  def statustext
    return Vod.Statuses[status] if status

    '?'
  end

  def statusclass
    ss = ['', 'info', 'active', 'info', 'success', 'active', 'success']
    return ss[status] if status
  end

  def prepare_encode
    self.status = 1
    self.encode_pos = 0
    save
  end

  def encode
    self.status = 1
    save

    make_ffcat

    self.status = 2
    save

    target_loudness = -23

    command = "nice -n20 ionice -c3 ffmpeg -accurate_seek -ss #{start_pos} -t #{end_pos - start_pos} " \
      "-i \"#{recording.filepath}/vod.ffcat\" " \
      "-filter_complex 'loudnorm=i=#{target_loudness}:print_format=json' -vn -sn -f null /dev/null 2>&1"

    logger.debug command

    loud = {}
    duration = nil
    prevpos = 0
    IO.popen(command) do |pipe|
      pipe.each("\r") do |line|
        #  Duration: 00:01:04.13, start: 0.000000, bitrate: 117511 kb/s
        if duration.nil? && (m = line.match(/Duration: (\d{2}):(\d{2}):(\d{2}).(\d{1})/))
          duration = ((m[1].to_i * 60 + m[2].to_i) * 60 + m[3].to_i) * 100 + m[4].to_i
        end

        # size=N/A time=00:03:47.90 bitrate=N/A speed=37.8x
        if (m = line.match(/time=(\d+):(\d+):(\d+).(\d+)/)) && (!duration.nil? && duration != 0)
          pos = ((m[1].to_i * 60 + m[2].to_i) * 60 + m[3].to_i) * 100 + m[4].to_i
          self.encode_pos = pos / 100
          prevpos = pos
          begin
            save
          rescue StandardError
          end
        end

        if (m = line.match(/Parsed_loudnorm_0.*(\{.*\})/m))
          loud = JSON.parse(m[1])
          pp loud
        end
      end
    end

    self.status = 3
    save

    if false
      intro_file = "#{recording.basepath}/intro.mov"
      outro_file = "#{recording.basepath}/outro.mov"

      command = "nice -n20 ionice -c3 ffmpeg -i \"#{intro_file}\" -accurate_seek -ss #{start_pos} -t #{end_pos - start_pos} " \
        "-i \"#{recording.filepath}/vod.ffcat\" -i \"#{outro_file}\" " \
        "-filter_complex '[1:v] fade=in:d=0.5,fade=out:d=0.5:st=#{end_pos - start_pos - 0.5} [fv];" \
        "[1:a] afade=in:d=0.5,afade=out:d=0.5:st=#{end_pos - start_pos - 0.5},loudnorm=i=#{target_loudness}:measured_i=#{loud['input_i']}:measured_lra=#{loud['input_lra']}:measured_tp=#{loud['input_tp']}:measured_thresh=#{loud['input_thresh']}:print_format=json [fa];"\
        "[0:v][0:a][fv][fa][2:v][2:a] concat=n=3:v=1:a=1 [outv] [outa]' -map '[outv]' -map '[outa]' " \
        '-b:a 192k -pix_fmt yuv420p -vcodec h264_nvenc -preset p6 -bufsize 50M -rc vbr -rc-lookahead 60 ' \
        "-qmin:v 19 -b:v 10M -maxrate:v 30M -movflags faststart -y \"#{vod_filepath}\" 2>&1"

    else
      command = format(
        'nice -n20 ionice -c3 ffmpeg -accurate_seek -ss %.2f -t %.2f -i "%s" -b:a 128k -pix_fmt yuv420p -vcodec h264_nvenc -preset p6 -bufsize 50M -rc vbr -rc-lookahead 60 -qmin:v 19 -b:v 10M -maxrate:v 30M -movflags faststart -y "%s" 2>&1 ', start_pos, end_pos - start_pos, "#{recording.filepath}/vod.ffcat", vod_filepath
      )
    end

    # logger.debug command
    Que.log event: :command, message: command

    progress = nil
    duration = nil
    prevpos = 0
    log = ''
    IO.popen(command) do |pipe|
      pipe.each("\r") do |line|
        log += line
        #  Duration: 00:01:04.13, start: 0.000000, bitrate: 117511 kb/s
        if line =~ (/Duration: (\d{2}):(\d{2}):(\d{2}).(\d{1})/) && duration.nil?
          duration = ((Regexp.last_match(1).to_i * 60 + Regexp.last_match(2).to_i) * 60 + Regexp.last_match(3).to_i) * 100 + Regexp.last_match(4).to_i
        end

        # frame=  497 fps= 79 q=26.0 size=    1655kB time=00:00:07.25 bitrate=1870.0kbits/s
        next unless line =~ /time=(\d+):(\d+):(\d+).(\d+)/ && (!duration.nil? && (duration != 0))

        pos = ((Regexp.last_match(1).to_i * 60 + Regexp.last_match(2).to_i) * 60 + Regexp.last_match(3).to_i) * 100 + Regexp.last_match(4).to_i
        # if pos - prevpos > 100
        self.encode_pos = pos / 100
        prevpos = pos
        begin
          save
        rescue StandardError
        end
        # end
      end
      pipe.close
    end
    ret = $?

    if ret != 0
      Que.log event: :cmdfail, message: ret
      Que.log event: :cmdlog, message: log
      raise StandardError, 'Encoding error'
    end

    if File.size(vod_filepath).zero?
      File.delete(vod_filepath)
      raise StandardError, 'Encoding error'
    end

    # xx if $?.exitstatus != 0
    self.encode_pos = length

    self.status = 4
    save

    system(format('nice -n20 ionice -c3 mp4file --optimize "%s"', vod_filepath))

    self.status = 5
    save
  end

  def prepare_upload
    self.status = 5
    self.encode_pos = 0
    save
  end

  def upload
    self.status = 5
    save

    #     Yt.configure do |config|
    #       config.client_id = '696179412564-a4iin9r2adn6ee51rflm8onvs2e7e3ks.apps.googleusercontent.com'
    #       config.client_secret = 'banqc5vbVAbdIKUZcvluYYR1'
    #     end
    #     account = Yt::Account.new access_token: 'ya29.wAEEpEzR88sTXyN-3k0AzIXRdBSQ6QQXmx9BVmg5F7SnWbJj0aJM_8w_ex2aUxVhFUwg', refresh_token: '1/weD693xQiwOhXbeqLbvjFq-pkfkN0pS7t9kdINHgkbbBactUREZofsF9C7PrpE-j'
    #
    #     vid = account.upload_video File.open(vod_filepath), title: name, description: 'Test upload', category: 'Entertainment', privacy_status: :private
    #
    #     #vid.id
    #
    command = format('youtube-upload  -t "%s" --privacy=unlisted "%s"  -c Entertainment 2>&1 ', name, vod_filepath)

    progress = nil
    duration = nil
    prevpos = 0
    IO.popen(command) do |pipe|
      pipe.each("\r") do |line|
        # frame=  497 fps= 79 q=26.0 size=    1655kB time=00:00:07.25 bitrate=1870.0kbits/s
        if line =~ / ([0-9]*)% /
          ep = Regexp.last_match(1).to_i / 100.0 * length
          if encode_pos != ep
            self.encode_pos = ep
            save
          end
        end
        if line =~ /^([A-Za-z0-9])$/
          self.youtube = Regexp.last_match(1)
          save
        end
      end
    end

    self.encode_pos = length

    self.status = 6
    save
  end

  def push_to_elaine
    resp = Net::HTTP.post_form(URI('http://elaine.assembly.org/programs/addprog'), name: name).body
    logger.debug resp
    self.elaineid = resp
  end
end
