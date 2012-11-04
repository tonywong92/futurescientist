# Add a declarative step here for populating the DB with movies.

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





# Make sure that one string (regexp) occurs before or after another one
#   on the same page

Then /I should see "(.*)" before "(.*)"/ do |e1, e2|
  #  ensure that that e1 occurs before e2.
  #  page.content  is the entire content of the page as a string.
  content = page.body
  currentLine = 0
  e1Line = 0
  e2Line = 0
  content.each_line do |line|
    currentLine += 1
    if line.include? e1
      e1Line = currentLine
    end
    if line.include? e2
      e2Line = currentLine
    end
  end
  if e2Line < e1Line
    assert false
  end
end

# Make it easier to express checking or unchecking several boxes at once
#  "When I uncheck the following ratings: PG, G, R"
#  "When I check the following ratings: G"

When /I (un)?check the following ratings: (.*)/ do |uncheck, rating_list|
  # HINT: use String#split to split up the rating_list, then
  #   iterate over the ratings and reuse the "When I check..." or
  #   "When I uncheck..." steps in lines 89-95 of web_steps.rb
 if uncheck == "un"
    rating_list.split(', ').each do |rate|
      step "I uncheck \"ratings_#{rate}\""
    end
  else
    rating_list.split(', ').each do |rate|
      step "I check \"ratings_#{rate}\""
    end
  end
end

Then /I should see all of the movies/ do ||
  step "I should see \"Amelie\""
  step "I should see \"Raiders of the Lost Ark\""
  step "I should see \"The Incredibles\""
  step "I should see \"The Terminator\""
  step "I should see \"When Harry Met Sally\""
  step "I should see \"2001: A Space Odyssey\""
  step "I should see \"Aladdin\""
  step "I should see \"Chicken Run\""
  step "I should see \"Chocolat\""
  step "I should see \"The Help\""
end

Then /^the director of "([^"]*)" should be "([^"]*)"$/ do |director, title|
  Movie.where("title = ?", title).each do |mov|
    if mov[:director] != director
      assert false
    end
  end
end


Given /^the blog is set up$/ do
  Blog.default.update_attributes!({:blog_name => 'Teh Blag',
                                   :base_url => 'http://localhost:3000'});
  Blog.default.save!
  User.create!({:login => 'admin',
                :password => 'aaaaaaaa',
                :email => 'joe@snow.com',
                :profile_id => 1,
                :name => 'admin',
                :state => 'active'})
end


Given /^a nonadmin exists$/ do
    User.create!({:login => 'nonadmin',
                :password => 'aaaaaaaa',
                :email => 'bob@snow.com',
                :profile_id => 2,
                :name => 'blog publisher',
                :state => 'active'})
end

And /^I am logged in as a nonadmin user$/ do
  visit '/accounts/login'
  fill_in 'user_login', :with => 'nonadmin'
  fill_in 'user_password', :with => 'aaaaaaaa'
  click_button 'Login'
  if page.respond_to? :should
    page.should have_content('Login successful')
  else
    assert page.has_content?('Login successful')
  end
end


Given /^"(.*)" exists with body "(.*)"$/ do |title, body|
  step "I am on the new article page"
  step "I fill in \"article_title\" with \"#{title}\""
  step "I fill in \"article__body_and_extended_editor\" with \"#{body}\""
  step "I press \"Publish\""
end


