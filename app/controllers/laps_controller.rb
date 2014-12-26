class LapsController < ApplicationController
  before_action :set_lap, only: [:show, :edit, :update, :destroy]

  # GET /laps
  # GET /laps.json
  def index
    @laps = Run.find(params[:run_id]).laps
  end

  # GET /laps/1
  # GET /laps/1.json
  def show
  end

  # GET /laps/new
  def new
    @lap = Lap.new
  end

  # GET /laps/1/edit
  def edit
  end

  # POST /laps
  # POST /laps.json
  def create
    @lap = Lap.new(lap_params)

    respond_to do |format|
      if @lap.save
        format.html { redirect_to @lap, notice: 'Lap was successfully created.' }
        format.json { render :show, status: :created, location: @lap }
      else
        format.html { render :new }
        format.json { render json: @lap.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /laps/1
  # PATCH/PUT /laps/1.json
  def update
    respond_to do |format|
      if @lap.update(lap_params)
        format.html { redirect_to @lap, notice: 'Lap was successfully updated.' }
        format.json { render :show, status: :ok, location: @lap }
      else
        format.html { render :edit }
        format.json { render json: @lap.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /laps/1
  # DELETE /laps/1.json
  def destroy
    @lap.destroy
    respond_to do |format|
      format.html { redirect_to laps_url, notice: 'Lap was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lap
      @run = Run.find(params[:run_id])
      @lap = @run.laps.find_by_number(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def lap_params
      params[:lap]
    end
end
