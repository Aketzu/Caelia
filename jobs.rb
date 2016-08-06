#!/usr/bin/ruby

require 'rufus-scheduler'
require 'rails'

require 'streamio-ffmpeg'


scheduler = Rufus::Scheduler.new

ROOTPATH="/mnt/asmvid/capture"

sfs = {}

Sourcefile.all.includes(:recording).each {|s|
 sfs[s.recording_id.to_s + "-" + s.filename] = s
}


#scheduler.every '5min' do
  Dir.glob(ROOTPATH + "/*").sort.each { |fn|
Sourcefile.transaction {
    if File.directory?(fn)
      progname = File.basename(fn)
      #Recording.transaction {
      rec = Recording.find_or_create_by(basepath: ROOTPATH, name: progname)
      #rec.save

      Dir.glob(fn + "/*.nut").sort.each {|f|
        file = File.basename(f)
        print progname + "/" + file + "\r"
	sf = sfs[rec.id.to_s + "-" + file]
        sf = Sourcefile.find_or_create_by(recording: rec, filename: file) unless sf
        sf.recorded_at = File.mtime(f) unless sf.recorded_at
        sf.check_preview
        sf.nr = sf.filename.gsub(/[^0-9]/,"").to_i

        unless sf.length
          movie = FFMPEG::Movie.new(f)
          sf.length = movie.duration
        end
        sf.save
      }

      #}
    end
}
  }
#end


#scheduler.join
  # let the current thread join the scheduler thread
