class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.integer :phonenumber
      t.string :location
      t.string :skills
      t.string :verifiedskills

      t.timestamps
    end
  end
end
