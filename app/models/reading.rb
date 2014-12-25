# http://api.wunderground.com/api/#{WUNDERGROUND_API_KEY}/history_20141224/q/pws:KAZTUCSO192.json
class Reading < ActiveRecord::Base
  belongs_to :weather
  belongs_to :station

  delegate :lat, :lon, to: :station

end
