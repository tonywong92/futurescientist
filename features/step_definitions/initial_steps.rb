Then /^I should (not )?see an element "([^"]*)"$/ do |negate, selector|
	expectation = negate ? :should_not : :should
	page.send(expectation, have_css(selector))
end

Given /the following problems exists/ do |problems_table|
  problems_table.hashes.each do |problem|
    # each returned element will be a hash whose key is the table header.
    # you should arrange to add that movie to the database here.
  problem = Problem.new(problem)
  problem.save!
  end
end
