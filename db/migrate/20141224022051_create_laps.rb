class CreateLaps < ActiveRecord::Migration
  def change
    create_table :laps do |t|
      t.references :run, index: true
      t.string  :number
      t.datetime    :begin_at
      t.datetime    :end_at
      t.float   :distance
      t.float   :duration
      t.float   :mean_heart_rate
      t.float   :mean_pace
      t.float   :mean_stride_length
      t.float   :mean_cadence
      t.float   :mean_gct
      t.float   :mean_vertical_oscillation

      t.timestamps null: false
    end
    add_foreign_key :laps, :runs
  end
end
