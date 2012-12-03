class Problem < ActiveRecord::Base
  @@TEXTLENGTH = 160
  @@DESCRIPTION_LIMIT = @@TEXTLENGTH * 4
  @@LOCATION_LIMIT = @@TEXTLENGTH/4
  @@SUMMARY_LIMIT = @@TEXTLENGTH/2

  attr_accessible :description, :location, :skills, :summary, :price, :archived, :wage

  belongs_to :user

  validates :location, :presence => true
  validates :skills, :presence => true
  validates :summary, :presence => true
  validates :wage, :presence => true

  validates_length_of :description, :maximum => @@DESCRIPTION_LIMIT, :allow_blank => true
  validates_length_of :location, :maximum => @@LOCATION_LIMIT, :allow_blank => false
  validates_length_of :summary, :maximum => @@SUMMARY_LIMIT, :allow_blank => false

  def to_s
    return "id:#{self.id}. @#{self.location} !#{self.skills} ##{self.summary} "# $#{self.price} "
  end

  def more_detail
    description = self.description
    if description == nil
      description = "None"
    end
    return "id:#{self.id}. Description: #{description} Phone: #{self.user.phone_number} "
  end

  def self.DESCRIPTION_LIMIT
    @@DESCRIPTION_LIMIT
  end

  def self.LOCATION_LIMIT
    @@LOCATION_LIMIT
  end

  def self.SUMMARY_LIMIT
    @@SUMMARY_LIMIT
  end
end
