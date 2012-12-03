class Skill < ActiveRecord::Base
 before_create do
    self.skill_name = skill_name.strip.downcase if attribute_present?("skill_name")
 end

  before_update do
    self.skill_name = skill_name.strip.downcase if attribute_present?("skill_name")
  end

  attr_accessible :skill_name
end
