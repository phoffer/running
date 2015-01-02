class AddElevationToLaps < ActiveRecord::Migration
  def change
    add_column :laps, :elevation_gain, :float
    add_column :laps, :elevation_loss, :float
  end
end
