class Account < ActiveRecord::Base
  attr_accessible :admin, :email, :account_name, :password, :skills, :verified_skills
  
  belongs_to :user
  has_many :problems, :through => :users

  validates :account_name, :presence => true
  validates :password, :presence => true
  validates_uniqueness_of :account_name

end
