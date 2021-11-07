# frozen_string_literal: true

class Sourcefile < ActiveRecord::Base
  belongs_to :recording

  def preview_file
    "preview_#{File.basename(filename, '.nut')}.jpg"
  end

  def preview_path
    "#{recording.name}/#{preview_file}"
  end

  def preview_fullpath
    "#{recording.basepath}/#{preview_path}"
  end

  def video_path
    "#{recording.name}/#{filename}"
  end

  def video_fullpath
    "#{recording.basepath}/#{video_path}"
  end

  def video_path_mp4
    fn = "#{recording.name}/#{File.basename(filename, '.nut')}.mp4"
    # Create MP4 version for Chrome
    fullpath = "#{recording.basepath}/#{fn}"
    unless File.exist?(fullpath)
      # system("ffmpeg -v 0 -i \"%s\" -c:v copy -c:a copy \"%s\"" % [recording.basepath+"/"+video_path, recording.basepath+"/"+fn])
      # system("ffmpeg -init_hw_device vaapi=foo:/dev/dri/renderD128 -hwaccel vaapi -hwaccel_output_format vaapi -hwaccel_device foo -i \"%s\" -filter_hw_device foo -vf 'hwupload,fps=10,scale_vaapi=w=1280:h=-2:format=nv12' -c:v h264_vaapi -level 40 -b:v 2M -maxrate 2M -c:a aac -y \"%s\"" % [recording.basepath+"/"+video_path, recording.basepath+"/"+fn])
      logger.debug(format('ffmpeg -i "%s" -preset fast -pix_fmt yuv420p -vcodec h264_nvenc -c:a copy "%s"',
                          "#{recording.basepath}/#{video_path}", fullpath))
      system(format(
               'ffmpeg -hwaccel_output_format cuda -hwaccel cuvid -i "%s" -preset fast -pix_fmt yuv420p -vcodec h264_nvenc -c:a copy "%s"', "#{recording.basepath}/#{video_path}", fullpath
             ))
      if File.size(fullpath).zero?
        File.delete(fullpath)
        return ''
      end
      system(format('mp4file --optimize "%s"', "#{recording.basepath}/#{fn}"))
    end

    fn
  end

  def check_preview
    # previewfile = "preview_" + File.basename(f, ".nut") + ".jpg"
    unless File.exist?(preview_fullpath)
      system(format('ffmpeg -v 0 -i "%s" -vframes 1 -s 320x180 "%s"', video_fullpath, preview_fullpath))
    end
  end

  def start_pos
    Sourcefile.where(recording_id: recording_id).where('nr < :nr', nr: nr).sum(:length)
  end

  def self.file_at(recording, pos)
    return Recording.find(recording).sourcefiles.first unless pos

    res = ActiveRecord::Base.connection.exec_query("select max(id) from (select id, length, sum(length) over (order by id asc) as cum_len from sourcefiles where recording_id = #{recording}) t where cum_len - length < #{pos}")
    id = 0
    res.each do |r|
      id = r['max']
    end
    Sourcefile.find(id)
  end

  def <=>(other)
    nr <=> other.nr
  end
end
