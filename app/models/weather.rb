class Weather < ActiveRecord::Base
  has_many :readings, dependent: :destroy
  belongs_to :running, polymorphic: true
end
