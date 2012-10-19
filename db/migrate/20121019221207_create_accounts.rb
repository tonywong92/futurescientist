class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :name
      t.string :password
      t.boolean :admin
      t.string :email
      t.references 'users'

      t.timestamps
    end
  end
end
