class CreateStations < ActiveRecord::Migration
  def change
    create_table :stations do |t|

      t.string :pws_id
      t.string :neighborhood
      t.string :city
      t.string :state
      t.string :country
      t.float  :lat
      t.float  :lon
      t.timestamps null: false
    end
  end
end
