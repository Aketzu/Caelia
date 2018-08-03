class EncodeJob < Que::Job
  def run(jobid)
    @vod = Vod.find(jobid)
    begin
      @vod.encode
    rescue Exception => ex
      logger.error ex.message
      logger.error ex.backtrace
    end
  end
end
