require 'net/http'

class Vod < ActiveRecord::Base
  belongs_to :recording

  def length
    return 0 unless end_pos and start_pos
    end_pos - start_pos
  end

  def make_ffcat
    File.open(recording.basepath + "/" + recording.name + "/vod.ffcat", File::WRONLY | File::TRUNC | File::CREAT) { |f|
      f.puts "ffconcat version 1.0"
      recording.sourcefiles.sort.each {|sf|
        f.puts "file " + sf.filename
        f.puts "duration 30"
      }
    }
  end

  def title_fn
    self.name.scan(/./).map { |ch| ch.gsub(/ /, '_').gsub(/[^A-Za-z0-9_]/,'')  }.flatten.join("")
  end

  def vod_filepath
    return recording.basepath+"/" + self.elaineid.to_s + "_" + title_fn + ".mp4" if self.elaineid and self.elaineid > 0
    recording.basepath+"/vod_"+id.to_s + ".mp4"
  end

  def self.Statuses
    ["New", "Prepare encode", "Encoding", "Optimizing", "VOD done", "Uploading", "Tube'd"]
  end

  def statustext
    return Vod.Statuses[status] if status
    "?"
  end

  def statusclass
    ss = ["", "info", "active", "info", "success", "active", "success"]
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
    command="nice -n20 ionice -c3 ffmpeg -accurate_seek -ss %.2f -t %.2f -i \"%s\" -b:a 128k -pix_fmt yuv420p -vcodec h264_nvenc -preset slow -bufsize 50M -rc vbr_hq -qmin:v 19 -b:v 10M -maxrate:v 30M -y \"%s\" 2>&1 " % [start_pos, end_pos - start_pos, recording.filepath + "/vod.ffcat", vod_filepath ]

    logger.debug command

    progress = nil
    duration = nil
    prevpos = 0
    IO.popen(command) do |pipe|
      pipe.each("\r") do |line|

        #  Duration: 00:01:04.13, start: 0.000000, bitrate: 117511 kb/s
        if line =~ /Duration: (\d{2}):(\d{2}):(\d{2}).(\d{1})/ and duration.nil?
          duration = (($1.to_i * 60 + $2.to_i) * 60 + $3.to_i) * 100 + $4.to_i
        end

        #frame=  497 fps= 79 q=26.0 size=    1655kB time=00:00:07.25 bitrate=1870.0kbits/s
        if line =~ /time=(\d+):(\d+):(\d+).(\d+)/
          if not duration.nil? and duration != 0
            pos = (($1.to_i * 60 + $2.to_i) * 60 + $3.to_i) * 100 + $4.to_i
            #if pos - prevpos > 100
              self.encode_pos = pos/100
              prevpos = pos
              begin
                save
              rescue
              end
            #end
          end
        end
      end
    end

    if File.size(vod_filepath) == 0
      File.delete(vod_filepath)
      raise Exception.new("Encoding error")
    end

    #xx if $?.exitstatus != 0
    self.encode_pos = self.length

    self.status = 3
    save

    system("nice -n20 ionice -c3 mp4file --optimize \"%s\"" % [vod_filepath])

    self.status = 4
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

=begin
    Yt.configure do |config|
			config.client_id = '696179412564-a4iin9r2adn6ee51rflm8onvs2e7e3ks.apps.googleusercontent.com'
			config.client_secret = 'banqc5vbVAbdIKUZcvluYYR1'
		end
		account = Yt::Account.new access_token: 'ya29.wAEEpEzR88sTXyN-3k0AzIXRdBSQ6QQXmx9BVmg5F7SnWbJj0aJM_8w_ex2aUxVhFUwg', refresh_token: '1/weD693xQiwOhXbeqLbvjFq-pkfkN0pS7t9kdINHgkbbBactUREZofsF9C7PrpE-j'

		vid = account.upload_video File.open(vod_filepath), title: name, description: 'Test upload', category: 'Entertainment', privacy_status: :private

		#vid.id

=end
    command="youtube-upload  -t \"%s\" --privacy=unlisted \"%s\"  -c Entertainment 2>&1 " % [name, vod_filepath ]

    progress = nil
    duration = nil
    prevpos = 0
    IO.popen(command) do |pipe|
      pipe.each("\r") do |line|

        #frame=  497 fps= 79 q=26.0 size=    1655kB time=00:00:07.25 bitrate=1870.0kbits/s
        if line =~ / ([0-9]*)% / 
          ep = $1.to_i/100.0*self.length
          if self.encode_pos != ep
            self.encode_pos = ep 
            save
          end
        end
        if line =~ /^([A-Za-z0-9])$/
          self.youtube = $1
          save
        end
      end
    end

    self.encode_pos = self.length

    self.status = 6
    save

  end

  def push_to_elaine
    resp = Net::HTTP.post_form(URI("http://elaine.assembly.org/programs/addprog"), name: self.name).body
    logger.debug resp
    self.elaineid = resp
  end
end
