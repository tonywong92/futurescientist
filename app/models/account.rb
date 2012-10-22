class Account < ActiveRecord::Base
  attr_accessible :admin, :email, :name, :password, :skills, :verified_skills
  
  belongs_to :user
  has_many :problems, :through => :users

  validates :name, :presence => true
  validates :password, :presence => true

end
