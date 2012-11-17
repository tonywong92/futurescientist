class Problem < ActiveRecord::Base
  attr_accessible :description, :location, :skills, :summary, :price

  belongs_to :user

  validates :location, :presence => true
  validates :skills, :presence => true
  validates :summary, :presence => true
 #validates :price, :presence => true

  def to_s
    return "id:#{self.id}. @#{self.location} !#{self.skills} ##{self.summary} $#{self.price} "
  end

  def more_detail
    description = self.description
    if description == nil
      description = "None"
      return "id:#{self.id}. Description: #{description} Phone Number: #{self.user.phone_number} "
  end
end
