class Account < ActiveRecord::Base
  attr_accessible :admin, :email, :account_name, :password, :skills, :verified_skills

  serialize :skills
  serialize :verified_skills
  
  belongs_to :user

  has_many :problems, :through => :users

  validates :account_name, :presence => true
  validates :password, :presence => true
  validates_uniqueness_of :account_name

  after_initialize :init

  def init
    self.skills ||= []
    self.verified_skills ||= []
  end

end
