class Account < ActiveRecord::Base
  :belongs_to user
  :has_many problems, :through => :users

  validates :name, :presence => true
  validates :password, :presence => true

  attr_accessible :admin, :email, :name, :password
  
end
