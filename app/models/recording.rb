class Recording < ActiveRecord::Base
  ROOT="/home/stream/src/bmdtools/"

  def preview_file
    "preview_" + File.basename(filename, ".nut") + ".jpg"
  end
  def preview_path
    path + "/" + preview_file
  end
  def video_path
    path + "/" + filename
  end
  def video_path_mp4
    fn = path + "/" + File.basename(filename, ".nut") + ".mp4"
    unless File.exists?(ROOT + fn)
      system("ffmpeg -i \"%s\" -c:v copy -c:a copy \"%s\"" % [ROOT+video_path, ROOT+fn])
      system("mp4file --optimize \"%s\"" % [ROOT+fn])
    end

    fn
  end
end
