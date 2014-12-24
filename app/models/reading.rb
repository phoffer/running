class Reading < ActiveRecord::Base
  belongs_to :weather
  belongs_to :station
end
