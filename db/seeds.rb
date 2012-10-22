# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
Skill.create!(:skill_name => 'water')

user = User.new({ :name => "dummy1", :phone_number=> 1231231234, :location => "Address1"})
user.save!
problem = Problem.new({ :location => "Address1", :skills => "water", :summary => "wires", :description => "description1"})
user.problems << problem
user.save!
puts problem.user
puts problem.user.name
puts problem.user.phone_number
puts problem.user_id
