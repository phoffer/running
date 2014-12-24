class CreateShoes < ActiveRecord::Migration
  def change
    create_table :shoes do |t|
      t.references :user, index: true
      t.float :miles
      t.integer :expectation
      t.decimal :cost
      t.string :location

      t.timestamps null: false
    end
    add_foreign_key :shoes, :users
  end
end
