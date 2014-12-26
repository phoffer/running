class CreateUsers < ActiveRecord::Migration
  def change
    execute 'create extension hstore'
    create_table :users do |t|
      t.string :email
      t.string :crypted_password
      t.hstore :accounts
      t.hstore :settings
      t.hstore :goal_race

      t.timestamps null: false
    end
  end
end
