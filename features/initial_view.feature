Feature: users should be able to see the front page

Background:
  Given the site is set up
  And I log out

Scenario: View the header
	Given I am on the home page
	Then I should see an element "#log_in"
	And I should see an element "#submit_new_problem"
	And I should see "Submit New Problem"
	And I should see "Log In"
  And I should see "Future Scientists"

Scenario: View the listings table
	Given I am on the home page
  Then I should see an element "#listings_table"
	And I should see "Location"
	And I should see "Skills"
	And I should see "Wage"
	And I should see "Problem Summary"

Scenario: View the table cells
  Given the following problems exists:
  | location | skills          | summary           | description       | wage |
  | Address1 | water           | broken water pipe | water pipe broken | 50   |
  | Address3 | water, mold     | roof is leaking   | roof is leaking   | 50   |
  
  Given I am on the home page
  Then I should see "Address1"
  And I should see "water"
  And I should see "broken water pipe"
  And I should see "water, mold"
  And I should see "roof is leaking"
  And I should see "Address3"
  And I should see "50"
