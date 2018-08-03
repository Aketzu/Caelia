class UploadJob < Que::Job
  def run(jobid)
    @vod = Vod.find(jobid)
    begin
      @vod.upload
    rescue Exception => ex
      logger.error ex.message
      logger.error ex.backtrace
    end
  end
end
