class Account < ActiveRecord::Base
  attr_accessible :admin, :email, :name, :password
  
  belongs_to :user
  has_many :problems, :through => :users

  validates :account_name, :presence => true
  validates :password, :presence => true

end
