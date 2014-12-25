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

  def get_readings
    # get readings after finding stations
  end
  def get_stations
    # get nearby stations
  end
  def details
    # get run details
    return @details if @details
    json = JSON.parse(open("http://connect.garmin.com/proxy/activity-service-1.3/json/activityDetails/#{self.garmin_id}").read)["com.garmin.activity.details.json.ActivityDetails"]
    items    = json['measurements'].sort_by { |h| h['metricsIndex'] }.map { |h| h['key'].underscore.gsub(/\A[^_]+_/, '').to_sym }
    @details = json['metrics'].map { |arr| items.zip(arr['metrics']).each_with_object({}) {|(k,v), hash| hash[k] = v } }
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
      json = data.is_a?(Hash) ? data : get_source(data)
      attributes = new_from_json(json['activity']) do |attributes|
        attributes[:begin_at]  = Time.parse(attributes[:begin_at])
        attributes[:end_at]    = Time.parse(attributes[:end_at])
        # attributes[:mean_pace] = attributes[:mean_pace].gsub(/\A0/, '')
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
    def get_source(activity_id)
      JSON.parse(open("http://connect.garmin.com/proxy/activity-service-1.3/json/activity/#{activity_id}").read)
    end
  end
end
