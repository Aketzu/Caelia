#!/usr/bin/ruby

require 'rufus-scheduler'
require 'rails'

require 'streamio-ffmpeg'


scheduler = Rufus::Scheduler.new

ROOTPATH="/home/stream/src/bmdtools"

#scheduler.every '5min' do
  Dir.glob(ROOTPATH + "/*").sort.each { |fn|
    if File.directory?(fn)
      progname = File.basename(fn)
      rec = Recording.find_or_create_by(basepath: ROOTPATH, name: progname)
      #rec.save

      Dir.glob(fn + "/*.nut").sort.each {|f|
        file = File.basename(f)
        print progname + "/" + file + "\r"
        sf = Sourcefile.find_or_create_by(recording: rec, filename: file)
        sf.recorded_at = File.mtime(f)
        sf.check_preview
        sf.nr = sf.filename.gsub(/[^0-9]/,"").to_i

        unless sf.length
          movie = FFMPEG::Movie.new(f)
          sf.length = movie.duration
        end
        sf.save
      }
    end
  }
#end

#scheduler.join
  # let the current thread join the scheduler thread
