class Shoe < ActiveRecord::Base
  belongs_to :user
  has_many :runs

  scope :active,   -> { where(status: 0) }
  scope :inactive, -> { where(status: 1) }
  scope :usable,   -> { where.not(status: 2) }

  after_create :set_unique


  STATUS = %i{active inactive retired}

  def set_unique
    others = self.class.where(brand: self.brand, model: self.model, version: self.version, color: self.color)
    if others.size != 1
      others.update_all(unique: false)
      self.update_attribute(:unique, false)
    end
  end
  def unique?
    self.unique
  end
  def name
    self.unique? ? "#{model} #{version} - #{color}" : "#{model} #{version} #{color} - #{letter}"
  end
  def status
    STATUS[read_attribute(:status)||0]
  end
  def status=(status)
    write_attribute(:status, STATUS.index(status.to_sym))
  end

  def update_miles
    update_attribute(:miles, self.runs.pluck(:distance).inject(:+))
  end
  def default_for?(cat = nil)
    self.defaults.include? cat
  end

  class << self
    def default_for(cat = nil)
      self.usable.detect { |shoe| shoe.default_for?(cat) }
    end
    def set_default(cat, shoe_id)
      previous = default_for(cat)
      current  = find_by_id(shoe_id)
      previous.update_attribute(:defaults, previous.defaults - Array(cat))
      current.update_attribute(:defaults, current.defaults + Array(cat))
    end
  end
end
