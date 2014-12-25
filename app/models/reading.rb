# http://api.wunderground.com/api/#{WUNDERGROUND_API_KEY}/history_20141224/q/pws:KAZTUCSO192.json
class Reading < ActiveRecord::Base
  belongs_to :weather
  belongs_to :station

  delegate :lat, :lon, to: :station

  class << self
    def attribute_paths
      {
        time:       %w{date pretty},
        temp:       %w{tempi},
        humidity:   %w{hum}
      }
    end
    def new_from_wunderground(data = nil, station: nil, time: nil)
      data ||= get_source(station, time)
      attributes = data['history']['observations'].map do |json|
        new_from_json(json) do |attributes|
          attributes[:time]  = Time.parse(attributes[:time])
        end
      end
    end
    def new_from_json(json)
      attributes = attribute_paths.each_with_object({}) do |(name, path), hash|
        hash[name] = json
        while k = path.shift
          hash[name] = hash[name][k]
        end
      end
      yield attributes
      new(attributes)
    end
    def get_source(station, time)
      JSON.parse(open("http://api.wunderground.com/api/#{ENV['WUNDERGROUND_API_KEY']}/history_#{time.strftime('%Y%m%d')}/q/pws:#{station}.json").read)
    end
  end
end
