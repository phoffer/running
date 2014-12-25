class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :crypted_password
      t.json :accounts
      t.json :settings
      t.json :goal_race

      t.timestamps null: false
    end
  end
end
