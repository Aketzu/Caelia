# frozen_string_literal: true

class EncodeJob < Que::Job
  def run(jobid)
    @vod = Vod.find(jobid)
    begin
      @vod.encode
    rescue StandardError => e
      Que.log event: :foo, message: e.message
      Que.log event: :bar, message: e.backtrace
    end
  end
end
