# frozen_string_literal: true

class EncodeJob < Que::Job
  def run(jobid)
    @vod = Vod.find(jobid)
    begin
      @vod.encode
    rescue StandardError => e
      Que.log text: e.message
      Que.log text: e.backtrace
    end
  end
end
