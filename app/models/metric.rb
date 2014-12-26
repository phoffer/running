class Metric
  attr_accessor :pws, :reading, :multipled_temp, :multipled_hum, :custom_data, :seconds, :data
  def initialize(arr)
    @data = arr
  end
  def time
    Time.at(@data[:timestamp] / 1000)
  end
  def method_missing(method, *args)
    @data[method]
  end
  def latitude
    @data[:latitude]
  end
  def longitude
    @data[:longitude]
  end
  def latlong
    [@data[:latitude], @data[:longitude]]
  end
  def to_s
    inspect
  end

  class << self
    def init_multiple(metrics)
      metrics.map{ |hash| new(hash) }
    end
  end
end