class CalendarController < ApplicationController
  # before_action :set_time
  # around_action :set_events

  def show
    @start_date   = Date.today.beginning_of_month
    monthly
  end
  def monthly
    @calendar_method  = :month_calendar
    @calendar_options = {}
    @start_date ||= Date.new(params[:year].to_i, params[:month].to_i, 1)
    @end_date     = @start_date.end_of_month
    @start_view   = @start_date.beginning_of_week
    @end_view     = @end_date.end_of_week
    set_events
  end
  def weekly
    @calendar_method  = :week_calendar
    if params[:start_date]
      @start_date   = Date.parse(params[:start_date])
      @end_date     = params[:end_date] ? Date.parse(params[:end_date]) : Date.today.end_of_week
    else
      @end_date     = Date.today.end_of_week
      @start_date   = @end_date.weeks_ago(7).beginning_of_week
    end
    @start_view, @end_view = @start_date, @end_date
    @calendar_options = {number_of_weeks: (@end_date - @start_date) / 7}
    set_events
  end
  private
  def set_events
    params[:start_date] = @start_date
    @runs = current_user.runs.time_range(@start_view, @end_view)
    @calendar_options.merge!({events: @runs, timezone: ActiveSupport::TimeZone.new('America/Phoenix')})
    render :show
  end
  def set_time
    @time = Time.now
    puts params.inspect
  end
end