Given /^the site is set up$/ do
  step "I am on the home page"
  step "I go to the create admin page"
  step "I fill in \"account_name\" with \"admin\""
  step "I fill in \"password\" with \"password\""
  step "I fill in \"name\" with \"Admin\""
  step "I fill in \"phone_number\" with \"1234567890\""
  step "I check \"Admin\""
  step "I press \"Create Account\""
  step "I should be on the problems page"
end

When /^I am logged in as an admin$/ do
  step "I go to the login page"
  step "I fill in \"account_account_name\" with \"admin\""
  step "I fill in \"account_password\" with \"password\""
  step "I press \"Login\""
  step "I should see \"Welcome, admin\""
end