Given /^the site is set up$/ do
  step "I am on the home page"
  step "I go to the create admin page"
  step "I fill in \"email\" with \"master@yahoo.com\""
  step "I fill in \"account_name\" with \"master\""
  step "I fill in \"password\" with \"Password\""
  step "I fill in \"name\" with \"Master\""
  step "I fill in \"phone_number\" with \"1234567890\""
  step "I check \"Admin\""
  step "I press \"Create Account\""
  step "I confirm through text"
  step "I press \"Continue to problems index\""
  step "I should be on the problems page"
end

When /^I am logged in as an admin$/ do
  step "I go to the login page"
  step "I fill in \"account_account_name\" with \"master\""
  step "I fill in \"account_password\" with \"Password\""
  step "I press \"Login\""
  step "I should see \"Welcome, master\""
end

Given /^the account is set up$/ do
  step "I am on the home page"
  step "I go to the create admin page"
  step "I fill in \"email\" with \"master2@yahoo.com\""
  step "I fill in \"account_name\" with \"master2\""
  step "I fill in \"password\" with \"Password\""
  step "I fill in \"name\" with \"Master\""
  step "I fill in \"phone_number\" with \"1234567890\""
  step "I press \"Create Account\""
  step "I confirm through text"
  step "I press \"Continue to problems index\""
  step "I should be on the problems page"
end

When /^I am logged in as a user$/ do
  step "I go to the login page"
  step "I fill in \"account_account_name\" with \"master2\""
  step "I fill in \"account_password\" with \"Password\""
  step "I press \"Login\""
  step "I should see \"Welcome, master2\""
end
