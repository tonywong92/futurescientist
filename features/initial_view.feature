Feature: users should be able to see the front page

Scenario: View the header
	Given I am on the home page
	Then I should see an element "#log_in"
	And I should see an element "#sign_up"
	And I should see an element "#post"

Scenario: View the listings table
	Given I am on the home page
  Then I should see an element "#listings_table"
