class Lap < ActiveRecord::Base
  belongs_to :run
  # has_one :weather, as: :running

  default_scope { order(number: :asc) }


  # delegate :temp, to: :weather, allow_nil: true

  before_update :update_pace
  after_update :update_run

  # accepts_nested_attributes_for :weather

  def update_pace
    if changes.include? 'distance'
      self.mean_pace = self.duration / self.distance / 60.0
      self.mean_stride_length = self.distance_in_meters / self.total_steps
    end
  end
  def update_run
    if changes.include? 'distance'
      self.run.update_distance
    end
  end
  def distance_in_meters
    self.distance * 1609.34
  end
  def total_steps
    self.mean_cadence * self.duration / 60.0
  end
  def pace
    Time.at(self.mean_pace*60).strftime("%M:%S").gsub(/\A0/, '')
  end
  def weather
    Weather.new(temp: self.temp, high: self.high, low: self.low, humidity: self.humidity, incline: self.incline)
  end

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
      elevation_gain: self.elevation_gain                   && self.elevation_gain.round,
      elevation_loss: self.elevation_loss                   && self.elevation_loss.round,
      stride_length:  self.mean_stride_length               && self.mean_stride_length.round(3),
      cadence:        self.mean_cadence                     && self.mean_cadence.round,
      gct:            self.mean_gct                         && self.mean_gct.round,
      vertical_oscillation: self.mean_vertical_oscillation  && self.mean_vertical_oscillation.round(2),
      duration:       Time.at(self.duration).utc.strftime(self.duration >= 3600 ? "%l:%M:%S" : "%M:%S").gsub(/\A0/, ''),
    }
  rescue => e
    update_attribute(:mean_pace, self.distance / self.duration)
    @retry ||= -1
    @retry += 1
    retry if @retry < 1
  end

  class << self
    def attribute_paths
      {
        begin_at:                   %w{BeginTimestamp value},
        end_at:                     %w{EndTimestamp value},
        distance:                   %w{SumDistance value},
        duration:                   %w{SumDuration value},
        elevation_gain:             %w{GainElevation value},
        elevation_loss:             %w{LossElevation value},
        mean_heart_rate:            %w{WeightedMeanHeartRate value},
        mean_pace:                  %w{WeightedMeanPace value},
        mean_stride_length:         %w{WeightedMeanStrideLength value},
        mean_cadence:               %w{WeightedMeanDoubleCadence value},
        mean_gct:                   %w{WeightedMeanGroundContactTime value},
        mean_vertical_oscillation:  %w{WeightedMeanVerticalOscillation value},
      }
    end
    def new_from_garmin(data, number)
      create(attributes_from_garmin(data, number))
    end
    def attributes_from_garmin(data, number)
      json = data
      attributes_from_json(json) do |attributes|
        attributes[:begin_at] = Time.at(("%f" % attributes[:begin_at].gsub('E', 'e')).to_i/1000)
        attributes[:end_at]   = Time.at(("%f" % attributes[:end_at].gsub('E', 'e')).to_i/1000)
        attributes[:number]   = number
        attributes[:elevation_loss] ||= 0
        attributes[:elevation_gain] ||= 0
      end
    end
    def attributes_from_json(json)
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
      attributes
    end
    def get_source(activity_id)
      JSON.parse(open("https://connect.garmin.com/proxy/activity-service-1.3/json/activity/#{activity_id}").read)
    end
  end
end
# Run.where(begin_at: (Date.today.beginning_of_year..Date.tomorrow), mean_heart_rate: (135..164) ).includes(:laps).pluck('laps.mean_pace');

# lap_info = Run.where(begin_at: (Date.today.beginning_of_year..Date.tomorrow), mean_heart_rate: (135..200), laps: {mean_pace: (1..9.9), distance: (0.4..3)} ).where.not(activity_type: 'treadmill_running').includes(:laps).pluck('laps.mean_pace', 'laps.temp', 'laps.mean_heart_rate','laps.distance', 'laps.elevation_gain', 'laps.elevation_loss')
# lap_info = Run.where(begin_at: (Date.today.beginning_of_year..Date.tomorrow.beginning_of_year+59), mean_heart_rate: (135..200), laps: {mean_pace: (1..9.9), distance: (0.4..3)} ).where.not(activity_type: 'treadmill_running').includes(:laps).pluck('laps.mean_pace', 'laps.temp', 'laps.mean_heart_rate','laps.distance', 'laps.elevation_gain', 'laps.elevation_loss')
# lap_info = Run.where(begin_at: (Date.today.beginning_of_year+59..Date.tomorrow), mean_heart_rate: (135..200), laps: {mean_pace: (1..9.9), distance: (0.4..3)} ).where.not(activity_type: 'treadmill_running').includes(:laps).pluck('laps.mean_pace', 'laps.temp', 'laps.mean_heart_rate','laps.distance', 'laps.elevation_gain', 'laps.elevation_loss')
# csv_str = lap_info.unshift(%w{pace temp heart_rate distance gain loss}).map {|lap| lap.to_csv }.join
# File.write('laps.csv', csv_str)