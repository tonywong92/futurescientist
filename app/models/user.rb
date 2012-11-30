class User < ActiveRecord::Base
PHONE_NUMBER_LENGTH_OF_COUNTRY = 12
before_validation do
    self.phone_number = sanitize phone_number if attribute_present?("phone_number")
end
attr_accessible :location, :name, :phone_number

 has_many :problems
 has_one :account

  validates :phone_number, :presence => true
  validate :validate_phone_number

  def sanitize number
    puts number
    number = number.gsub(/^\+*1/,"").gsub("-","").gsub(/\D/,"")
    number.insert(0,"+1")
    puts number
    number
  end

  def validate_phone_number
    if phone_number.length != PHONE_NUMBER_LENGTH_OF_COUNTRY
      errors.add(:phone_number, "is invalid")
    end
  end
end
