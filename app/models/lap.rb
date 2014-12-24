class Lap < ActiveRecord::Base
  belongs_to :run
  has_one :weather, as: :running
end
