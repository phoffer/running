# http://api.wunderground.com/api/e9a4d2a67eb6aec7/geolookup/q/32.23773,-111.02152.json
require 'open-uri'
class Station
  # copied from original weather app. need something to help with matching for run points
  attr_reader :data
  # @@list = []
  def initialize(hash)
    @data = hash
  end
  def method_missing(method, *args)
    @data[method.to_s]
  end
  def distance(lat, lon = nil)
    latlong = lon ? [lat.to_f, lon.to_f] : lat.map(&:to_f)
    Haversine.distance(latlong, [self.lat, self.lon])
  end
  def readings(time = nil)
    @readings
  end
  def get_readings(time = Time.now)
    url = "history_#{time.strftime('%Y%m%d')}/q/pws:#{self.id}.json"
    json = JSON.parse(open("http://api.wunderground.com/api/#{ENV['WUNDERGROUND_API_KEY']}/history_#{time.strftime('%Y%m%d')}/q/pws:#{self.id}.json").read)
    # @readings = json['history']["observations"].map { |hash| Reading.new(hash) }
    @readings = Reading.new_from_wunderground(json)
  end

  class << self
    # def list
    #   @@list
    # end
    def closest(lat, lon = nil, list)l
      latlong = lon ? [lat.to_f, lon.to_f] : lat.map(&:to_f)
      list.min_by{ |pws| pws.distance(latlong) }
    end
    def init_multiple(arr_of_pws, lat = nil, lon = nil, pws_blacklist = [])
      arr_of_pws.map { |hash| self.new(hash) }.reject{ |pws| pws_blacklist.include? pws.id}
    end
    # def sort_distance(*latlong)
    #   self.list.sort_by! { |pws| pws.distance(latlong) }
    # end
    def lookup(lat, lon = nil)
      latlong = lon ? [lat.to_f, lon.to_f] : lat.map(&:to_f)
      url = "http://api.wunderground.com/api/#{ENV['WUNDERGROUND_API_KEY']}/geolookup/q/#{latlong.join(',')}.json" # 37.776289,-122.395234
      json = JSON.parse(Net::HTTP.get(URI url))
      init_multiple(json['location']['nearby_weather_stations']['pws']['station'])
    end
  end
end
