# frozen_string_literal: true

class UploadJob < Que::Job
  def run(jobid)
    @vod = Vod.find(jobid)
    begin
      @vod.upload
    rescue Exception => e
      logger.error e.message
      logger.error e.backtrace
    end
  end
end
