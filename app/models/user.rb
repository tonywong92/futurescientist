class User < ActiveRecord::Base
USA_PHONE_NUMBER_LENGTH = 12
before_validation do
    self.phone_number = sanitize phone_number if attribute_present?("phone_number")
end
attr_accessible :location, :name, :phone_number

 has_many :problems
 has_one :account

  validates :phone_number, :presence => true
  validate :validate_phone_number
  validates_uniqueness_of :phone_number
  validates_length_of :location, :maximum => Problem.LOCATION_LIMIT, :allow_blank => true

  def sanitize number
    number = number.gsub(/^\+1/,"").gsub("+","").gsub("-","").gsub(/\D/,"")
    number.insert(0,"+1")
    number
  end

  def validate_phone_number
    if phone_number.length != USA_PHONE_NUMBER_LENGTH
      errors.add(:phone_number, "is invalid")
    end
  end
end
