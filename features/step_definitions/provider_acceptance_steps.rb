Given /^I have created the following "(.*?)" provider accounts with the following fields:$/ do |skill, table|
  table.hashes.each do |account|
    acc = Account.new(:email => account['Email'], :account_name => account['Account Name'], :password => account['Password'])
    acc.verified_skills = [skill]
    acc.verified = true
    user = User.new(:name => account['Name'], :phone_number => account['Phone Number'], :location => account['Location'])
    user.account = acc
    user.save
    acc.save
  end
end

When /^I click on "(.*?)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^there should be no remaining problems$/ do
  pending # express the regexp above with the code you wish you had
end
