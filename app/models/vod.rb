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

  def encode
    make_ffcat
    logger.info("nice -n20 ionice -c3 ffmpeg -accurate_seek -ss %.2f -t %.2f -i \"%s\" -b:a 128k -x264opts level=4.1:crf=20 -preset fast -y \"%s\"" % [start_pos, end_pos - start_pos, recording.filepath + "/vod.ffcat", recording.filepath+"/vod_"+id.to_s + ".mp4"])
    system("nice -n20 ionice -c3 ffmpeg -accurate_seek -ss %.2f -t %.2f -i \"%s\" -b:a 128k -x264opts level=4.1:crf=20 -preset fast -y \"%s\"" % [start_pos, end_pos - start_pos, recording.filepath + "/vod.ffcat", vod_filepath ])
    system("nice -n20 ionice -c3 mp4file --optimize \"%s\"" % [vod_filepath])
  end

  def upload
    client = YouTubeIt::Client.new(:username => YOUTUBE_USERNAME, :password => YOUTUBE_PASSWORD, :dev_key => YOUTUBE_DEVKEY)
    client.video_upload(File.open(vod_filepath), :title => "Test", :description => "Test", :category => "Entertainment", :private => true)

  end
end
