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

  def vod_filepath
    recording.filepath+"/vod_"+id.to_s + ".mp4"
  end

  def self.Statuses
    ["New", "Prepare encode", "Encoding", "Optimizing", "VOD done", "Uploading", "Tube'd"]
  end
  def statustext
    return Vod.Statuses[status] if status
    "?"
  end

  def encode
    self.status = 1
    save

    make_ffcat

    self.status = 2
    save
    command="nice -n20 ionice -c3 ffmpeg -accurate_seek -ss %.2f -t %.2f -i \"%s\" -b:a 128k -x264opts level=4.1:crf=20 -preset fast -y \"%s\" 2>&1 " % [start_pos, end_pos - start_pos, recording.filepath + "/vod.ffcat", vod_filepath ]

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
              save
            #end
          end
        end
      end
    end

    #xx if $?.exitstatus != 0

    self.status = 3
    save

    system("nice -n20 ionice -c3 mp4file --optimize \"%s\"" % [vod_filepath])

    self.status = 4
    save
  end

  def upload
    self.status = 5
    save
    client = YouTubeIt::Client.new(:username => YOUTUBE_USERNAME, :password => YOUTUBE_PASSWORD, :dev_key => YOUTUBE_DEVKEY)
    client.video_upload(File.open(vod_filepath), :title => name, :description => "Test upload", :category => "Entertainment", :private => true)
    self.status = 6
    save

  end
end
