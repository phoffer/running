class ChangeLapNumberToInteger < ActiveRecord::Migration
  def up
   change_column :laps, :number, 'integer USING CAST(number AS integer)'
  end

  def down
   change_column :laps, :number, :string
  end
end
