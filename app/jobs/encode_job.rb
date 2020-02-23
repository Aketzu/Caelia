class EncodeJob < Que::Job
  def run(jobid)
    @vod = Vod.find(jobid)
    begin
      @vod.encode
    rescue StandardError => ex
      Que.log text: ex.message
      Que.log text: ex.backtrace
    end
  end
end
