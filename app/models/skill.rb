class Skill < ActiveRecord::Base
 before_create do
    self.password = skill_name.strip.downcase if attribute_present?("skill_name")
 end

  before_update do
    self.password = skill_name.strip.downcase if attribute_present?("skill_name")
  end

  attr_accessible :skill_name
end
