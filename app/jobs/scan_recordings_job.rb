# frozen_string_literal: true

# ROOTPATH = '/mnt/asmvid/rec'.freeze
# ROOTPATH = '/tank0/asm/s17/rec'.freeze
ROOTPATH = '/tank0/asm/ct21/rec'
require 'streamio-ffmpeg'

class ScanRecordingsJob < Que::Job
  def run(foo)
    puts foo
    puts foo.inspect
    sfs = {}

    Sourcefile.all.includes(:recording).each do |s|
      sfs["#{s.recording_id}-#{s.filename}"] = s
    end

    Dir.glob("#{ROOTPATH}/*").sort.each do |fn|
      Sourcefile.transaction do
        next unless File.directory?(fn)

        progname = File.basename(fn)
        # Recording.transaction {
        rec = Recording.find_or_create_by(basepath: ROOTPATH, name: progname)
        # rec.save

        Dir.glob("#{fn}/*.nut").sort.each do |f|
          next if File.zero?(f)

          file = File.basename(f)
          print "#{progname}/#{file}\r"
          sf = sfs["#{rec.id}-#{file}"]
          sf ||= Sourcefile.find_or_create_by(recording: rec, filename: file)
          sf.recorded_at = File.mtime(f) unless sf.recorded_at

          sf.check_preview
          sf.nr = sf.filename.gsub(/[^0-9]/, '').to_i

          if !sf.length || sf.length < 20 || (Time.now - sf.recorded_at).to_i < 400
            movie = FFMPEG::Movie.new(f)
            sf.length = movie.duration - movie.time
          end
          sf.save
        end
      end
    end
  end
end
