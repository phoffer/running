class CreateShoes < ActiveRecord::Migration
  def change
    create_table :shoes do |t|
      t.references :user, index: true
      t.string  :brand
      t.string  :model
      t.integer :version
      t.string  :letter
      t.float   :miles
      t.integer :expectation
      t.decimal :cost
      t.string  :location

      t.timestamps null: false
    end
    add_foreign_key :shoes, :users
  end
end
