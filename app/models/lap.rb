class Lap < ActiveRecord::Base
  belongs_to :run
  has_one :weather, as: :running
  delegate :temp, to: :weather, allow_nil: true

  def time_range
    (self.begin_at..self.end_at)
  end
  def time
    self.begin_at.in_time_zone(self.run.time_zone)
  end
  def distance
    self.attributes['distance'].round(2)
  end
  def display
    {
      distance:       self.attributes['distance'].round(2),
      pace:           Time.at(self.mean_pace*60).strftime("%M:%S").gsub(/\A0/, ''),
      stride_length:  self.mean_stride_length.round(3),
      cadence:        self.mean_cadence.round,
      gct:            self.mean_gct.round,
      vertical_oscillation: self.mean_vertical_oscillation.round(2),
      duration:       Time.at(self.duration).utc.strftime(self.duration >= 3600 ? "%l:%M:%S" : "%M:%S").gsub(/\A0/, ''),
    }
  end

  class << self
    def attribute_paths
      {
        begin_at:                   %w{BeginTimestamp value},
        end_at:                     %w{EndTimestamp value},
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
      json = data
      attributes = new_from_json(json) do |attributes|
        attributes[:begin_at] = Time.at(("%f" % attributes[:begin_at].gsub('E', 'e')).to_i/1000)
        attributes[:end_at]   = Time.at(("%f" % attributes[:end_at].gsub('E', 'e')).to_i/1000)
        attributes[:number]   = number
      end
    end
    def new_from_json(json)
      attributes = attribute_paths.each_with_object({}) do |(name, path), hash|
        begin
          hash[name] = json
          while k = path.shift
            hash[name] = hash[name][k]
          end
        rescue
          hash.delete(name)
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
