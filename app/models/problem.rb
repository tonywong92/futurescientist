class Problem < ActiveRecord::Base
  attr_accessible :description, :location, :skills, :summary, :price

  belongs_to :user

  validates :location, :presence => true
  validates :skills, :presence => true
  validates :summary, :presence => true
 #validates :price, :presence => true

  def to_s
    return "#{self.id}. @#{self.location} !#{self.skill} ##{self.summary} $#{self.price} "
  end

  def more_detail
    return "#{self.id}. #{self.description} Phone Number: #{self.user.phone_number} "
  end
end
