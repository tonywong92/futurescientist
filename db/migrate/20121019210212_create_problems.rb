class CreateProblems < ActiveRecord::Migration
  def change
    create_table :problems do |t|
      t.string :location
      t.string :skills
      t.string :summary
      t.text :description
      t.float :price
      t.references 'user'
      t.boolean :archived, :default => false

      t.timestamps
    end
  end
end
