class RunsController < ApplicationController
  before_action :set_run, only: [:show, :edit, :update, :destroy, :weather, :create_weather]

  # GET /runs
  # GET /runs.json
  def index
    # @runs = Run.all
    @activities = current_user.activities(includes: [:shoe])
  end

  def stats
    @chart_data = if params[:filters]
      @form = StatsForm.new(stats_params)
      stuff_to_pluck = ['mean_pace', 'temp', 'mean_heart_rate','distance', 'elevation_gain', 'elevation_loss']
      lap_data = Run.where(@form.filters).where.not(activity_type: 'treadmill_running').includes(:laps).pluck(*stuff_to_pluck.map{|p|p.prepend('laps.')}).transpose
      lap_data[0].map! { |f| f.round(2) }
      series = [{
          name: 'Temp vs Pace',
          color: 'rgba(223, 83, 83, .5)',
          data: lap_data[1].zip(lap_data[0]).select(&:all?)
        },
        {
          name: 'HR vs Pace',
          color: 'rgba(119, 152, 191, .5)',
          data: lap_data[2].zip(lap_data[0]).select(&:all?)

        }
      ]
      regressions = series.map {|h| StatsPack.new(*h[:data].transpose) }
      set_data = regressions.map { |r| {m: r.slope, b: r.intercept, line: [[r.xs.min, r.predict(r.xs.min)], [r.xs.max, r.predict(r.xs.max)]]} }
      puts set_data
      {
        permalink: request.original_fullpath,
        series:    series,
        regressions: set_data
      }
    else
      @form = StatsForm.new
      nil
    end
    # puts @chart_data.to_json
    respond_to do |format|
      format.html { render :stats }
      format.json { render json: @chart_data, layout: false }
    end
  end

  def weather
    @weather = @run.conditions
  end
  def create_weather
    @weather = @run.conditions
    respond_to do |format|
      format.html { redirect_to request.referrer }
      format.json { render json: @run, layout: false }
    end
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
    @run = current_user.create_run(params[:garmin_id])
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
          current_user.shoes.find(shoe_id).update_miles
          # @run.shoe.update_miles # move this to callback, so it can get triggered after updating laps. need to update run.miles and shoe.miles
        end
        format.html { redirect_to request.referrer, notice: 'Run was successfully updated.' }
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
      @run      = current_user.runs.find(params[:id])
      @laps     = @run.laps
      @weather  = @run.weather
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def run_params
      params.require(:run).permit(:shoe_id, :temp, laps_attributes: [:id, :distance, :temp])
    end
    def stats_params
      # i hate everything about this form cluster
      params[:filters][:begin_after]  = date_from_date_select_fields(params[:filters], :begin_after)
      params[:filters][:begin_before] = date_from_date_select_fields(params[:filters], :begin_before)
      params[:filters].select! { |_, v| v.present? }
      params[:filters][:laps].select! { |_, v| v.present? }
      params.require(:filters).permit(:hr_above, :hr_below, :begin_after, :begin_before, laps: [:mean_pace, :distance])
    end
    def date_from_date_select_fields(params, name)
      parts = (1..3).map do |e|
        params.delete("#{name}(#{e}i)").to_i
      end

      # remove trailing zeros
      # parts = parts.slice(0, parts.rindex{|e| e != 0}.to_i + 1)
      return nil if parts[0] == 0  # empty date fields set

      Date.new(*parts)
    end
end
