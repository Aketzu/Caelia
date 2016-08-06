class Sourcefile < ActiveRecord::Base
  belongs_to :recording

  def preview_file
    "preview_" + File.basename(filename, ".nut") + ".jpg"
  end
  def preview_path
    recording.name + "/" + preview_file
  end
  def preview_fullpath
    recording.basepath + "/" + preview_path
  end
  def video_path
    recording.name + "/" + filename
  end
  def video_fullpath
    recording.basepath + "/" + video_path
  end

  def video_path_mp4
    fn = recording.name + "/" + File.basename(filename, ".nut") + ".mp4"
    #Create MP4 version for Chrome
    unless File.exists?(recording.basepath + "/" + fn)
      system("ffmpeg -v 0 -i \"%s\" -c:v copy -c:a copy \"%s\"" % [recording.basepath+"/"+video_path, recording.basepath+"/"+fn])
      system("mp4file --optimize \"%s\"" % [recording.basepath+"/"+fn])
    end

    fn
  end

  def check_preview
    #previewfile = "preview_" + File.basename(f, ".nut") + ".jpg"
    unless File.exists?(preview_fullpath)
      system("ffmpeg -v 0 -i \"%s\" -vframes 1 -s 320x180 \"%s\"" % [video_fullpath, preview_fullpath])
    end
  end

  def <=>(b)
    self.nr <=> b.nr
  end
end
