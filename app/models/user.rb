class User < ActiveRecord::Base
attr_accessible :location, :name, :phonenumber, :skills, :verifiedskills

 has_many :problems

  validates :name, :presence => true
  validates :phonenumber, :presence => true

end
