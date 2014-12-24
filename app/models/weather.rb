class Weather < ActiveRecord::Base
  has_many :readings
  belongs_to :running, polymorphic: true
end
