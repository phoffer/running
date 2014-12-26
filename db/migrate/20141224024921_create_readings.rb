class CreateReadings < ActiveRecord::Migration
  def change
    create_table :readings do |t|
      t.references :weather, index: true
      # t.references :station, index: true

      t.string :pws_id
      t.datetime   :time
      t.float  :temp
      t.float  :humidity

      t.timestamps null: false
    end
    add_foreign_key :readings, :weathers
    # add_foreign_key :readings, :stations
  end
end
