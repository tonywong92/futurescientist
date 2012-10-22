When /^I fill in the following fields:$/ do |table|
  table.hashes.each do |account|
    step "I fill in \"email\" with \"#{account[:email]}\""
    step "I fill in \"account_name\" with \"#{account[:account_name]}\""
    step "I fill in \"password\" with \"#{account[:password]}\""
    step "I fill in \"name\" with \"#{account[:name]}\""
    step "I fill in \"email\" with \"#{account[:phone_number]}\""
    step "I fill in \"location\" with \"#{account[:location]}\"" 
  end
end

When /^I log in with email "(.*?)" and password "(.*?)"$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

Then /^I should be successfully logged in$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should see the "(.*?)" error$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^I fill in the "(.*?)" field with $/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^I fill in the "(.*?)" field with Tester$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^I fill in the "(.*?)" field with password$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^I fill in the "(.*?)" field with Test$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^I fill in the "(.*?)" field with (\d+)$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

When /^I fill in the "(.*?)" field with Panama$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^I should see the Missing Email error$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I fill in the "(.*?)" field with tester@something\.com$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^I should see the Missing Account Name error$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should see the Missing Password error$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should see the Missing Name error$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should see the Missing Phone Number error$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should see the Missing Location error$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I fill in the "(.*?)" field with fail\-email$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^I should see the Invalid Email error$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I click on the "(.*?)" problem by "(.*?)" at "(.*?)"$/ do |arg1, arg2, arg3|
  pending # express the regexp above with the code you wish you had
end

When /^I press 'edit'$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I change 'water' to 'water, mold' in the 'skills relevant' field$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I change 'water pipe broken' to 'water pipe broken and is causing mold' in the 'description' field$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I press 'submit'$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should see 'water, mold'$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should see 'water pipe broken and is causing mold'$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I click on the 'broken water pipe' problem by 'Bob' at 'Address(\d+)'$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^I press 'delete'$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should see 'are you sure you want to delete this problem\?'$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I click on 'yes'$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should not see the 'broken water pipe' problem at 'Address(\d+)'$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^I click on the 'broken water pipe' problem by 'John' at 'Address(\d+)'$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^I should see an optional "(.*?)" text box$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^I should see a problem with the description "(.*?)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end
