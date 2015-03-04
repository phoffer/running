class Weather
  attr_reader :temp, :high, :low, :humidity, :incline
  def initialize(temp: nil, high: nil, low: nil, humidity: nil, incline: nil)
    @temp     = temp
    @high     = high
    @low      = low
    @humidity = humidity
    @incline  = incline
  end
end
