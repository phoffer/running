class Shoe < ActiveRecord::Base
  belongs_to :user
  has_many :runs

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

end
