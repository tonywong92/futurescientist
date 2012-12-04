# Add a declarative step here for populating the DB with movies.


# TODO!!!! WAGE MUST BE A FLOAT. CUCUMBER WILL PASS IT IN AS A STRING. MUST CONVERT BEFORE CREATING A PROBLEM.
Given /^"(.*?)" created the following problems:$/ do |name, problems_table|
  user = User.find_by_name(name)
  problems_table.hashes.each do |problem|
    # each returned element will be a hash whose key is the table header.
    # you should arrange to add that movie to the database here.
  problem = Problem.new(problem)
  problem.save!
  user.problems << problem
  user.save!
  end
end

Given /the following users exist/ do |users_table|
  users_table.hashes.each do |user|
    # each returned element will be a hash whose key is the table header.
    # you should arrange to add that movie to the database here.
  User.create!(user)
  end
end

Given /^"(.*)" has an account with name "(.*)" and password "(.*)"$/ do |name, account, password|
  hsh = { :account => account, :password => password, :admin => false }
  account = Account.new(hsh)
  account.save!
  user.account = account
  user.save!
end

Given /^I am logged in as "(.*)"$/ do |user|
  user = User.find_by_name(user)
  account = user.account
  visit '/'
  fill_in 'account_login', :with => '#{account.account_name}'
  fill_in 'account_password', :with => '#{account.password}'
  click_button 'Login'
end