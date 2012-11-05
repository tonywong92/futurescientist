Given /the following account exists/ do |account_table|
  account_table.hashes.each do |account|
    # each returned element will be a hash whose key is the table header.
    # you should arrange to add that movie to the database here.
  Account.create!(account)
  end
end
