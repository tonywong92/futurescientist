require 'rubygems'
require 'openssl'
require 'base64'
require 'cgi'
require 'hmac-sha1'

class Account < ActiveRecord::Base
  @@PUBLIC_KEY = '1234'
  include ActiveModel::Dirty

  before_create do
    self.password = Account.to_hmac password if attribute_present?("password")
  end

  before_update do
    if self.password_changed?
      self.password = Account.to_hmac password
    end
  end

  attr_accessible :admin, :email, :account_name, :password, :skills, :verified_skills, :verified

  serialize :skills
  serialize :verified_skills

  belongs_to :user

  has_many :problems, :through => :users

  validates :email, :presence => true
  validates :account_name, :presence => true
  validates :password, :presence => true
  validates_uniqueness_of :email
  validates_uniqueness_of :account_name

  after_initialize :init

  def init
    self.skills ||= []
    self.verified_skills ||= []
  end

  def self.has_password? string
    if self.password == to_hmac(string)
      return true
    else
      return false
    end
  end

  def self.to_hmac string
    hmac = HMAC::SHA1.new(@@PUBLIC_KEY)
    hmac.update(string)
    return hmac.to_s
  end

  def self.PUBLIC_KEY
    @@PUBLIC_KEY
  end
end
