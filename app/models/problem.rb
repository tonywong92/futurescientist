class Problem < ActiveRecord::Base
  attr_accessible :description, :location, :skills, :summary, :price

  belongs_to :user

  validates :location, :presence => true
  validates :skills, :presence => true
  validates :summary, :presence => true
 #validates :price, :presence => true

end
