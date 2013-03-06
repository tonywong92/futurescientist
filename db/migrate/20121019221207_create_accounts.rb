class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :phone_number
      t.string :account_name
      t.string :name
      t.string :location
      t.string :password
      t.boolean :admin, :default => false
      t.string :email
      t.boolean :verified, :default => false

      t.timestamps
    end
  end
end
