Given /^I add the "(.*)" skill to the database$/ do |skill|
  Skill.create!(:skill_name => skill)
end

When /^I fill in the following fields:$/ do |table|
  table.hashes.each do |account|
    step "I fill in \"email\" with \"#{account['Email']}\""
    step "I fill in \"account_name\" with \"#{account['Account Name']}\""
    step "I fill in \"password\" with \"#{account['Password']}\""
    step "I fill in \"name\" with \"#{account['Name']}\""
    step "I fill in \"phone_number\" with \"#{account['Phone Number']}\""
    step "I fill in \"location\" with \"#{account['Location']}\"" 
  end
end

Then /^I should see the "(.*?)" error$/ do |error_message|
  case error_message
    when /^Missing Account Name$/
      message = "Account name can't be blank"
    when /^Missing Password$/
      message = "Password can't be blank"
    when /^Missing Name$/
      message = "Name can't be blank"
    when /^Missing Phone Number$/
      message = "Phone number can't be blank"
  end
  step "I should see \"#{message}\""
end
