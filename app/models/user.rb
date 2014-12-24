class User < ActiveRecord::Base
  has_many :shoes
  has_many :runs
  store_accessor :accounts, :garmin_id, :garmin_username
end
