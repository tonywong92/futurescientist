Feature: users should be able to see the front page

Scenario: View the listings table
	Given I am on the "home"
  When I go to the edit page for "Alien"
  Then I should see the "listings_table"
  
Scenario: Enter the login page
	Given I am on the "home" page
	And I click on the "Login" button
	Then I should be redirected to the login page
