class CreateSkillVerifications < ActiveRecord::Migration
  def change
    create_table :skill_verifications do |t|
      t.integer :account_id
      t.timestamps
    end
  end
end
