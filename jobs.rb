#!/usr/bin/ruby

require 'rufus-scheduler'
require 'rails'

require 'streamio-ffmpeg'


scheduler = Rufus::Scheduler.new

ROOTPATH="/home/stream/src/bmdtools"

#scheduler.every '10s' do
  Dir.glob(ROOTPATH + "/*").sort.each { |fn|
    if File.directory?(fn)
      progname = File.basename(fn)
      Dir.glob(fn + "/*.nut").sort.each {|f|
        file = File.basename(f)
        puts file
        previewfile = "preview_" + File.basename(f, ".nut") + ".jpg"
        unless File.exists?(fn + "/" + previewfile)
          system("ffmpeg -i \"%s\" -vframes 1 \"%s\"" % [f, fn + "/" + previewfile])
        end

        rec = Recording.where(path: progname, filename: file).first
        unless rec
          rec = Recording.new(path: progname, filename: file)
          rec.save
        end
        rec.path = progname
        rec.recorded_at = File.ctime(f)

        unless rec.length
          movie = FFMPEG::Movie.new(f)
          rec.length = movie.duration
        end
        rec.save

      }
    end


  }
#end

#scheduler.join
  # let the current thread join the scheduler thread
