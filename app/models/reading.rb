class Reading < ActiveRecord::Base
  belongs_to :weather
  belongs_to :station

  delegate :lat, to: :station
  delegate :lon, to: :station

end
