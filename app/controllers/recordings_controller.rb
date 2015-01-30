class RecordingsController < ApplicationController
  def index
    if params[:path]
      @recordings = Recording.all.order(:filename).where(path: params[:path])
      @filelist = true
    else 
      @recordings = Recording.all.order(:path).group(:path)
      @filelist = false
    end
  end

  def picker
    @recording = Recording.find(params[:id])

  end
end
