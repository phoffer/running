require 'time'
require 'open-uri'
require 'set'
class Run < ActiveRecord::Base
  belongs_to :shoe
  belongs_to :user

  has_many :laps, dependent: :destroy
  has_one :weather, as: :running, dependent: :destroy
  has_many :readings, through: :weather

  # after_commit :update_distance

  default_scope { includes(:weather).order(begin_at: :desc) }

  delegate :temp, to: :weather, allow_nil: true
  accepts_nested_attributes_for :laps
  accepts_nested_attributes_for :weather

  TREADMILL_CODE = 'treadmill_running'.freeze
  CATEGORIES = %i{wet rain snow treadmill track race}

  def categories # maybe use this to help set default shoe automatically
    # options = %i{wet rain snow treadmill track race}
  end
  def treadmill?
    self.activity_type == TREADMILL_CODE
  end
  def weather_label
    self.treadmill? ? 'Incline' : 'Temp'
  end
  def incline
    self.treadmill? and self.weather_id and self.weather.temp
  end
  def distance_in_meters
    self.distance * 1609.34
  end
  def total_steps
    self.mean_cadence * self.duration / 60.0
  end
  def update_distance
    self.distance = self.laps.pluck(:distance).inject(:+)
    self.mean_pace = self.duration / self.distance / 60.0
    self.mean_stride_length = self.distance_in_meters / self.total_steps
    self.save
  end
  def pace
    Time.at(self.mean_pace*60).strftime("%M:%S").gsub(/\A0/, '')
  end
  # def distance
  #   self.attributes['distance'].round(2)
  # end
  def time
    self.begin_at.in_time_zone(self.time_zone)
  end
  def display
    {
      distance:       self.attributes['distance'].round(2),
      pace:           Time.at(self.mean_pace*60).strftime("%M:%S").gsub(/\A0/, ''),
      stride_length:        self.mean_stride_length        && self.mean_stride_length.round(3),
      cadence:              self.mean_cadence              && self.mean_cadence.round,
      gct:                  self.mean_gct                  && self.mean_gct.round,
      vertical_oscillation: self.mean_vertical_oscillation && self.mean_vertical_oscillation.round(2),
      duration:       Time.at(self.duration).utc.strftime(self.duration >= 3600 ? "%l:%M:%S" : "%M:%S").gsub(/\A0/, ''),
    }
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
    # @details = json['metrics'].map { |m| Metric.new(m) }
    @details = json['metrics'].map { |arr| Metric.new items.zip(arr['metrics']).to_h }
  end

  def build_laps(data = nil)
    data ||= self.class.get_source(self.garmin_id)
  end


  def latlong
    [self.latitude, self.longitude]
  end
  def nearby_stations
    Station.lookup(latlong)
  end
  def conditions(stats: [:temp, :humidity])
    return self.weather if self.weather
    return Weather.new if self.treadmill?
    metrics = self.details
    local_pws = nearby_stations
    pws_list = metrics.each_with_index.map do |m, i|
      if (ll = m.latlong) == [0.0, 0.0]
        j = i
        j -= 1 until (latlong = metrics[j].latlong) != [0.0, 0.0]
      end
      m.pws = Station.closest(ll, list: local_pws)
    end.uniq

    readings = pws_list.each_with_object({}) { |pws, hash| hash[pws.id] = pws.get_readings(self.time) }

    current_reading = nil
    useful = metrics.map do |m|
      begin
        until readings[m.pws.id].first.time > m.time
          current_reading = readings[m.pws.id].shift
        end
      rescue
        m.pws = Station.closest(m.latlong, list: local_pws - [m.pws])
        readings[m.pws.id] = m.pws.get_readings(self.time) unless readings.has_key?(m.pws.id)
        retry
      end
      m.reading = current_reading
    end
    c_d = stats.each_with_object({}) { |stat, c_d| c_d[stat] = useful.map{ |r| r.send(stat) } }
    avg = c_d.each_with_object({}) { |(k, arr), hash| hash[k] = (arr.inject(:+) / metrics.length).round(1) }
    self.create_weather(
      temp:         avg[:temp],
      high:         c_d[:temp].max,
      low:          c_d[:temp].min,
      humidity:     avg[:humidity],
      station_ids:  pws_list.map(&:id)
    )
    # generate weather for each lap
    metrics.chunk { |m| self.laps.detect{|l| l.time_range.cover? m.time } }.each do |lap, ary|
      c_d = stats.each_with_object({}) { |stat, c_d| c_d[stat] = ary.map{ |m| m.reading.send(stat) } }
      avg = c_d.each_with_object({}) { |(k, arr), hash| hash[k] = (arr.inject(:+) / ary.length).round(1) }
      lap.create_weather(
        temp:         avg[:temp],
        high:         c_d[:temp].max,
        low:          c_d[:temp].min,
        humidity:     avg[:humidity],
        station_ids:  pws_list.map(&:id)
      )
    end
    self.weather
  end

  class << self
    def attribute_paths
      {
        garmin_id:                  %w{activityId},
        activity_type:              %w{activityType key},
        event_type:                 %w{eventType key},
        begin_at:                   %w{activitySummary BeginTimestamp value},
        end_at:                     %w{activitySummary EndTimestamp value},
        time_zone:                  %w{activitySummary BeginTimestamp uom},
        latitude:                   %w{activitySummary BeginLatitude value},
        longitude:                  %w{activitySummary BeginLongitude value},
        distance:                   %w{activitySummary SumDistance value},
        duration:                   %w{activitySummary SumElapsedDuration value},
        mean_heart_rate:            %w{activitySummary WeightedMeanHeartRate bpm value},
        mean_pace:                  %w{activitySummary WeightedMeanPace value},
        mean_stride_length:         %w{activitySummary WeightedMeanStrideLength value},
        mean_cadence:               %w{activitySummary WeightedMeanDoubleCadence value},
        mean_gct:                   %w{activitySummary WeightedMeanGroundContactTime value},
        mean_vertical_oscillation:  %w{activitySummary WeightedMeanVerticalOscillation value},
      }
    end
    def find_or_create_from_garmin(data)
      run = find_by_garmin_id(data)
      return run if run
      json = get_source(data)
      run = new_from_json(json['activity']) do |attributes|
        attributes[:begin_at]  = Time.parse(attributes[:begin_at])
        attributes[:end_at]    = Time.parse(attributes[:end_at])
      end
      stored_max = (1.0 / json['activity']['activitySummary']['WeightedMeanHeartRate']['value'].to_f) * run.mean_heart_rate.to_f
      run.laps = json['activity']['totalLaps']['lapSummaryList'].map.with_index do |hash, i|
        hash['WeightedMeanHeartRate']['value'] = hash['WeightedMeanHeartRate']['value'].to_f * stored_max
        Lap.new_from_garmin(hash, i + 1)
      end
      run
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
