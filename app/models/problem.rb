class Problem < ActiveRecord::Base
  :belongs_to user

  validates :location, :presence => true
  validates :skills, :presence => true
  validates :summary, :presence => true

  attr_accessible :description, :location, :skills, :summary
end
