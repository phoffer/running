class User < ActiveRecord::Base
  has_many :shoes
  has_many :runs
  store_accessor :accounts, :garmin_id, :garmin_username
  store_accessor :settings, :blocked_pws, :stats



  def create_run(garmin_id)
    (self.runs << Run.find_or_create_from_garmin(garmin_id)).last
  end
  def activities(includes: false)
    run_arr = self.runs.includes(:shoe).to_a
    activity_ids.map { |id| run_arr.detect{ |r| r.garmin_id == id } || id }
  end

  private
  def activity_ids(limit = 1000, start = 1)
    activity_list(limit, start).map{ |hash| hash['activityId'] }
  end
  def activity_list(limit = 100, start = 1)
    return @activity_list if @activity_list
    uri = URI "https://connect.garmin.com/proxy/activitylist-service/activities/#{self.garmin_id}?start=#{start}&limit=#{limit}"
    @activity_list = JSON.parse(Net::HTTP.get(uri))['activityList']
  end

end
