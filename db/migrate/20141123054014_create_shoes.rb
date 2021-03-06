class CreateShoes < ActiveRecord::Migration
  def change
    create_table :shoes do |t|
      t.references :user, index: true
      t.string  :brand
      t.string  :model
      t.integer :version
      t.string  :letter,  default: 'a', limit: 1
      t.integer :status,  default: 0
      t.float   :miles,   default: 0
      t.integer :expectation
      t.string  :defaults,  array: true
      t.decimal :cost
      t.string  :location

      t.timestamps null: false
    end
    add_foreign_key :shoes, :users
  end
end
