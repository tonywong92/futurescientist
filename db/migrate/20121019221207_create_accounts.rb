class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :account_name
      t.string :password
      t.boolean :admin
      t.string :email
      t.string :skills
      t.string :verified_skills
      t.references 'users'

      t.timestamps
    end
  end
end
