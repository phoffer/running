class Shoe < ActiveRecord::Base
  belongs_to :user
  has_many :runs

  scope :active, -> { where(status: 0) }
  scope :inactive, -> { where(status: 1) }


  STATUS = %i{active inactive retired}

  def name
    "#{brand} #{model} #{version} - #{letter}"
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

end
