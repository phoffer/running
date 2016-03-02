class StatsPack < Regression::Linear
  attr_reader :xs, :ys
end
class StatsForm
  attr_reader :filters, :mean_heart_rate, :begin_at, :laps
  def initialize(stats_params = nil)
    return unless stats_params
    @graph_type = 1
    @filters = {
        hr_above:         135,
        hr_below:         200,
        begin_after:      Date.today.beginning_of_year,
        begin_before:     Date.tomorrow,
        laps: {
          pace_above: 1,
          pace_below: 9.9,
          distance_above: 0.4,
          distance_below: 3,
        }
      }.deep_merge(stats_params.to_h.transform_keys(&:to_sym))
      @filters.merge!({
        begin_at:         (@filters.delete(:begin_after)..@filters.delete(:begin_before)),
        mean_heart_rate:  (@filters.delete(:hr_above).to_i..@filters.delete(:hr_below).to_i),
        laps: {
          distance:  (@filters[:laps].delete(:distance_above).to_f..@filters[:laps].delete(:distance_below).to_f),
          mean_pace: (@filters[:laps].delete(:pace_above).to_f..@filters[:laps].delete(:pace_below).to_f),
        }
      })
  end
  def method_missing(method, *params)
    @filters[method.to_sym]
  end
  def begin_after
    @filters[:begin_at].begin
  end
  def begin_before
    @filters[:begin_at].end
  end
  def hr_above
    @filters[:mean_heart_rate].begin
  end
  def hr_below
    @filters[:mean_heart_rate].end
  end
end
