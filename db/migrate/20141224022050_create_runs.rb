class CreateRuns < ActiveRecord::Migration
  def change
    create_table :runs do |t|
      t.references :user, index: true
      t.references :shoe, index: true
      t.integer :garmin_id
      t.string  :activity_type
      t.string  :event_type
      t.time    :begin_at
      t.time    :end_at
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
    add_foreign_key :runs, :users
    add_foreign_key :runs, :shoes
  end
end
