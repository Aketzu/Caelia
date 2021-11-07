# frozen_string_literal: true

class RecordingsController < ApplicationController
  def index
    @recordings = Recording.all.where(hidden: false).order(:name)
  end

  def list
    @recording = Recording.find(params[:id])
    @vod = Vod.find(params[:vod]) if params[:vod]
  end

  def hide
    @recording = Recording.find(params[:id])
    @recording.hidden = true
    @recording.save!
    redirect_to recordings_index_path
  end
end
