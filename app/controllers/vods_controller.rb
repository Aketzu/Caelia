class VodsController < ApplicationController
  before_action :set_vod, only: [:show, :edit, :update, :destroy]

  # GET /vods
  # GET /vods.json
  def index
    @vods = Vod.all
  end

  # GET /vods/1
  # GET /vods/1.json
  def show
    if request.xhr? and params[:status] == "1"
      render partial: "status"

    end
  end

  # GET /vods/new
  def new
    @vod = Vod.new
  end

  # GET /vods/1/edit
  def edit
  end

  # POST /vods
  # POST /vods.json
  def create
    @vod = Vod.new(vod_params)

    respond_to do |format|
      if @vod.save
        format.html { redirect_to @vod, notice: 'Vod was successfully created.' }
        format.json { render :show, status: :created, location: @vod }
      else
        format.html { render :new }
        format.json { render json: @vod.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /vods/1
  # PATCH/PUT /vods/1.json
  def update
    respond_to do |format|
      if @vod.update(vod_params)
        format.html { redirect_to @vod, notice: 'Vod was successfully updated.' }
        format.json { render :show, status: :ok, location: @vod }
      else
        format.html { render :edit }
        format.json { render json: @vod.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /vods/1
  # DELETE /vods/1.json
  def destroy
    @vod.destroy
    respond_to do |format|
      format.html { redirect_to vods_url, notice: 'Vod was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def setpos
    @vod = Vod.find(params[:id])

    sf = Sourcefile.find(params[:sourcefile_id])

    @vod.start_pos = (sf.nr+1) * 30 + params[:timepos].to_f if params[:pos] == "start"
    @vod.end_pos = (sf.nr+1) * 30 + params[:timepos].to_f if params[:pos] == "end"

    respond_to do |format|
      if @vod.save
        format.html { redirect_to @vod, notice: 'Vod was successfully updated.' }
        format.json { render :show, status: :ok, location: @vod }
      else
        format.html { render :edit }
        format.json { render json: @vod.errors, status: :unprocessable_entity }
      end
    end
  end

  def dovod
    @vod = Vod.find(params[:id])
    job_id = Rufus::Scheduler.singleton.in '1s' do
      @vod.encode
    end

    respond_to do |format|
      format.html { redirect_to @vod, notice: "Vod job queued #{job_id}." }
      format.json { render :show, status: :ok, location: @vod }
    end
  end
  def upload
    @vod = Vod.find(params[:id])
    job_id = Rufus::Scheduler.singleton.in '1s' do
      @vod.upload
    end

    respond_to do |format|
      format.html { redirect_to @vod, notice: "Vod job queued #{job_id}." }
      format.json { render :show, status: :ok, location: @vod }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_vod
      @vod = Vod.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def vod_params
      params[:vod].permit(:name, :recording_id, :start_pos, :end_pos)
    end
end
