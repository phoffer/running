class RunsController < ApplicationController
  before_action :set_run, only: [:show, :edit, :update, :destroy]

  # GET /runs
  # GET /runs.json
  def index
    # @runs = Run.all
    @activities = @user.activities(includes: [:weather, :shoe])
  end

  # GET /runs/1
  # GET /runs/1.json
  def show
  end

  # GET /runs/new
  def new
    @run = Run.new
  end

  # GET /runs/1/edit
  def edit
  end

  # POST /runs
  # POST /runs.json
  def create
    @run = @user.create_run(params[:garmin_id])
    redirect_to request.referrer and return
    # @run = Run.new(run_params)

    respond_to do |format|
      if @run.save
        format.html { redirect_to @run, notice: 'Run was successfully created.' }
        format.json { render :show, status: :created, location: @run }
      else
        format.html { render :new }
        format.json { render json: @run.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /runs/1
  # PATCH/PUT /runs/1.json
  def update
    shoe_id = run_params[:shoe_id]
    respond_to do |format|
      if @run.update(run_params)
        if shoe_id
          @user.shoes.find(shoe_id).update_miles
          # @run.shoe.update_miles # move this to callback, so it can get triggered after updating laps. need to update run.miles and shoe.miles
        end
        format.html { redirect_to @run, notice: 'Run was successfully updated.' }
        format.json { render :show, status: :ok, location: @run }
      else
        format.html { render :edit }
        format.json { render json: @run.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /runs/1
  # DELETE /runs/1.json
  def destroy
    @run.destroy
    respond_to do |format|
      format.html { redirect_to runs_url, notice: 'Run was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_run
      @run      = @user.runs.find(params[:id])
      @laps     = @run.laps
      @weather  = @run.weather
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def run_params
      params.require(:run).permit(:shoe_id, laps_attributes: [:id, :distance, weather_attributes: [:id, :temp]], weather_attributes: [:id, :temp])
    end
end
