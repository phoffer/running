class AddTempToRuns < ActiveRecord::Migration
  def change
    add_column :runs, :temp, :float
    add_column :runs, :high, :float
    add_column :runs, :low, :float
    add_column :runs, :humidity, :float
    add_column :runs, :station_ids, :string
    add_column :runs, :incline, :float
    add_column :laps, :temp, :float
    add_column :laps, :high, :float
    add_column :laps, :low, :float
    add_column :laps, :humidity, :float
    add_column :laps, :station_ids, :string
    add_column :laps, :incline, :float
    Run.all.each do |run|
      if run.treadmill?
        run.incline     = run.weather.try(:temp)
      else
        run.temp        = run.weather.try(:temp)
        run.high        = run.weather.try(:high)
        run.low         = run.weather.try(:low)
        run.humidity    = run.weather.try(:humidity)
        run.station_ids = run.weather.try(:station_ids)
      end
      run.laps.each do |lap|
        if run.treadmill?
          lap.incline     = lap.weather.try(:temp)
        else
          lap.temp        = lap.weather.try(:temp)
          lap.high        = lap.weather.try(:high)
          lap.low         = lap.weather.try(:low)
          lap.humidity    = lap.weather.try(:humidity)
          lap.station_ids = lap.weather.try(:station_ids)
        end
        # lap.weather.delete
        lap.save
      end
      # run.weather.delete
      run.save
    end
  end
end
