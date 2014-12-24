require 'time'
require 'open-uri'
class Run < ActiveRecord::Base
  belongs_to :shoe
  belongs_to :user

  has_many :laps
  has_one :weather, as: :running
  has_many :readings, through: :weather

  # before_create :prepare_raw_data

  def pace
    # convert mean_pace to string 'xx:xx:xx'
  end

  class << self
    def attribute_paths
      {
        garmin_id:                 %w{activityId},
        activity_type:             %w{activityType key},
        event_type:                %w{eventType key},
        begin_at:                  %w{activitySummary BeginTimestamp value},
        end_at:                    %w{activitySummary EndTimestamp value},
        distance:                  %w{activitySummary SumDistance value},
        duration:                  %w{activitySummary SumElapsedDuration value},
        mean_heart_rate:           %w{activitySummary WeightedMeanHeartRate bpm value},
        mean_pace:                 %w{activitySummary WeightedMeanPace value},
        mean_stride_length:        %w{activitySummary WeightedMeanStrideLength value},
        mean_cadence:              %w{activitySummary WeightedMeanDoubleCadence value},
        mean_gct:                  %w{activitySummary WeightedMeanGroundContactTime value},
        mean_vertical_oscillation: %w{activitySummary WeightedMeanVerticalOscillation value},
      }
    end
    def new_from_garmin(data)
      json = data.is_a?(Hash) ? data : JSON.parse(open("http://connect.garmin.com/proxy/activity-service-1.3/json/activity/#{data}").read)
      attributes = attribute_paths.each_with_object({}) do |(name, path), hash|
        hash[name] = json['activity']
        while k = path.shift
          hash[name] = hash[name][k]
        end
      end
      attributes[:begin_at]  = Time.parse(attributes[:begin_at])
      attributes[:end_at]    = Time.parse(attributes[:end_at])
      # attributes[:mean_pace] = attributes[:mean_pace].gsub(/\A0/, '')
      new(attributes)
    end

  end
end
