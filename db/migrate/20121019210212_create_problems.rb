class CreateProblems < ActiveRecord::Migration
  def change
    create_table :problems do |t|
      t.string :location
      t.string :skills
      t.string :summary
      t.text :description
      t.integer :price
      t.references 'user' 
     
      t.timestamps
    end
  end
end
