ROOTPATH = '/mnt/asmvid/rec'.freeze
require 'streamio-ffmpeg'

class ScanRecordingsJob < Que::Job
  def run
    sfs = {}

    Sourcefile.all.includes(:recording).each do |s|
      sfs[s.recording_id.to_s + '-' + s.filename] = s
    end

    Dir.glob(ROOTPATH + '/*').sort.each do |fn|
      Sourcefile.transaction do
        next unless File.directory?(fn)
        progname = File.basename(fn)
        # Recording.transaction {
        rec = Recording.find_or_create_by(basepath: ROOTPATH, name: progname)
        # rec.save

        Dir.glob(fn + '/*.nut').sort.each do |f|
          file = File.basename(f)
          print progname + '/' + file + "\r"
          sf = sfs[rec.id.to_s + '-' + file]
          sf ||= Sourcefile.find_or_create_by(recording: rec, filename: file)
          sf.recorded_at = File.mtime(f) unless sf.recorded_at
          sf.check_preview
          sf.nr = sf.filename.gsub(/[^0-9]/, '').to_i

          unless sf.length
            movie = FFMPEG::Movie.new(f)
            sf.length = movie.duration
          end
          sf.save
        end
      end
    end
  end
end