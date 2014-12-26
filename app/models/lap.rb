class Lap < ActiveRecord::Base
  belongs_to :run
  has_one :weather, as: :running

  def time_range
    (self.begin_at..self.end_at)
  end
  def distance
    self.attributes['distance'].round(2)
  end

  class << self
    def attribute_paths
      {
        begin_at:                   %w{BeginTimestamp withUnitAbbr},
        end_at:                     %w{EndTimestamp withUnitAbbr},
        distance:                   %w{SumDistance value},
        duration:                   %w{SumDuration value},
        mean_heart_rate:            %w{WeightedMeanHeartRate value},
        mean_pace:                  %w{WeightedMeanPace value},
        mean_stride_length:         %w{WeightedMeanStrideLength value},
        mean_cadence:               %w{WeightedMeanDoubleCadence value},
        mean_gct:                   %w{WeightedMeanGroundContactTime value},
        mean_vertical_oscillation:  %w{WeightedMeanVerticalOscillation value},
      }
    end
    def new_from_garmin(data, number)
      json = data#.is_a?(Hash) ? data : get_source(data)
      attributes = new_from_json(json) do |attributes|
        attributes[:begin_at] = Time.parse(attributes[:begin_at])
        attributes[:end_at]   = Time.parse(attributes[:end_at])
        attributes[:number]   = number
      end
    end
    def new_from_json(json)
      attributes = attribute_paths.each_with_object({}) do |(name, path), hash|
        hash[name] = json
        while k = path.shift
          begin
          hash[name] = hash[name][k]
        rescue
          binding.pry
        end
        end
      end
      yield attributes
      create(attributes)
    end
    def get_source(activity_id)
      JSON.parse(open("http://connect.garmin.com/proxy/activity-service-1.3/json/activity/#{activity_id}").read)
    end
  end
end
