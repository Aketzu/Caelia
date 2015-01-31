class RecordingsController < ApplicationController
  def index
    @recordings = Recording.all.order(:name)
  end

  def list
    @recording = Recording.find(params[:id])
  end
end
