  class CreateWeathers < ActiveRecord::Migration
  def change
    create_table :weathers do |t|

      t.float :temp
      t.float :high
      t.float :low
      t.float :humidity
      t.string  :station_ids, array: true
      t.references :running, polymorphic: true, index: true

      t.timestamps null: false
    end
  end
end
