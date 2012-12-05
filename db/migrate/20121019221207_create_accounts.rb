class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :account_name
      t.string :password
      t.boolean :admin, :default => false
      t.string :email
      t.text :skills
      t.text :verified_skills
      t.boolean :verified, :default => false
      t.references 'user'

      t.timestamps
    end
  end
end
