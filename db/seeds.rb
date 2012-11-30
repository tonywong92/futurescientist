# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
Skill.create!(:skill_name => 'water')
Skill.create!(:skill_name => 'electricity')
Skill.create!(:skill_name => 'electronics')

user = User.new({ :name => "dummy1", :phone_number=> "1231231234", :location => "Address1"})
user.save!
user2 = User.new({ :name => "dummy2", :phone_number=> "5555557777", :location => "Address2"})
user2.save!
problem = Problem.new({ :location => "Address1", :skills => "electricity", :summary => "wires", :description => "description1"})
user.problems << problem
user.save!
problem2 = Problem.new({ :location => "Address1", :skills => "water", :summary => "water pipe broke", :description => "description2"})
user.problems << problem2
user.save!
problem3 = Problem.new({ :location => "Address2", :skills => "electronics", :summary => "radio broke", :description => "description3"})
user2.problems << problem3
user2.save!
