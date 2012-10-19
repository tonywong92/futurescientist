class User < ActiveRecord::Base
  :has_many problems

  validates :name, :presence => true
  validates :phonenumber, :presence => true

  attr_accessible :location, :name, :phonenumber, :skills, :verifiedskills
end
