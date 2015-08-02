class RecordingsController < ApplicationController
  def index
    @recordings = Recording.all.order(:name)
  end

  def list
    @recording = Recording.find(params[:id])
    @vod = Vod.find(params[:vod]) if params[:vod]
  end
end
