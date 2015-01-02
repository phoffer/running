class AddElevationToRuns < ActiveRecord::Migration
  def change
    add_column :runs, :elevation_gain, :float
    add_column :runs, :elevation_loss, :float
  end
end
