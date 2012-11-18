class SkillVerification < ActiveRecord::Base
  # attr_accessible :title, :body

  belongs_to :account, :dependent => true
end
