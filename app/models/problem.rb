class Problem < ActiveRecord::Base
  attr_accessible :description, :location, :skills, :summary

  belongs_to :user

  validates :location, :presence => true
  validates :skills, :presence => true
  validates :summary, :presence => true

end
