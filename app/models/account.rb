require 'rubygems'
require 'openssl'
require 'base64'
require 'cgi'
require 'hmac-sha1'

class Account < ActiveRecord::Base
  @@PUBLIC_KEY = '1234'
  include ActiveModel::Dirty
  
  USA_PHONE_NUMBER_LENGTH = 12
  before_validation do
    self.phone_number = sanitize phone_number if attribute_present?("phone_number")
  end

  before_create do
    self.password = Account.to_hmac password if attribute_present?("password")
  end

  before_update do
    if self.password_changed?
      self.password = Account.to_hmac password
    end
  end

  # only phone number is a required field. verified and admin can be set to true
  attr_accessible :phone_number, :account_name, :name, :location, :password, :admin, :email, :verified
  #:skills, :verified_skills

  #serialize :skills
  #serialize :verified_skills

  has_many :problems

  #validates :email, :presence => true
  #validates :account_name, :presence => true
  #validates :password, :presence => true
  #validates_uniqueness_of :email
  #validates_uniqueness_of :account_name
  #validate :validate_password, :unless => :persisted?
  #validate :validate_password_for_update, :if => :persisted?
  #validates_length_of :password, :minimum => 6, :allow_blank => false

  validates :phone_number, :presence => true
  validate :validate_phone_number
  validates_uniqueness_of :phone_number
  validates_length_of :location, :maximum => Problem.LOCATION_LIMIT, :allow_blank => true
  after_initialize :init

  def init
    #self.skills ||= []
    #self.verified_skills ||= []
  end

  def validate_phone_number
    if phone_number.length != USA_PHONE_NUMBER_LENGTH
      errors.add(:phone_number, "is invalid")
    end
  end
  
  def validate_password
    bool = (password =~ /[A-Z]{1}/) != nil
    if !bool
      errors.add(:password, " needs to have at least 1 capital letter")
    end
  end

  def validate_password_for_update
  #TODO: need a way to be able to validate the password when    doing an update. Right now, the encryption is a one way hash,     thus there's not a way I can check for a capital letter, when     it's already in the database, since we only save encrypted    passwords, and hmac only is a one way hash. Currently self-   checking...
  end
  
  def sanitize number
    number = number.gsub(/^\+1/,"").gsub("+","").gsub("-","").gsub(/\D/,"")
    number.insert(0,"+1")
    number
  end

  def has_password? string
    if password == Account.to_hmac(string)
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
