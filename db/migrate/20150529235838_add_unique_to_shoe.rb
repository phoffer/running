class AddUniqueToShoe < ActiveRecord::Migration
  def change
    add_column :shoes, :unique, :boolean, null: false, default: true
    Shoe.all.each(&:set_unique)
  end
end
