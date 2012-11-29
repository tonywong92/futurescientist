Feature:
  

Background:
    Given the site is set up
    Given I am on the problem submission page
	  And I select "water" from "skills"
	  And I fill in "Problem Summary" with "Broken Pipe"
	  And I press "Submit Problem"
    Given I add the "water" skill to the database
		Given I add the "electronics" skill to the database
    And I fill in the following fields:
        | Account Name | Password | Name | Phone Number | Location |
        | Tester       | Password | Test | 123456789    | Panama   |
    And I press "Create Account"
    And I confirm through text
    And I press "Continue to problems index"

Scenario: Checking account status as User
	Given I go to the profile page
	Then I should see "User"
	And I should not see "Admin"

Scenario: User should be able to interact with all of his submitted problems
  Given I am on the problem submission page
  And I select "water" from "skills"
  And I fill in "Problem Summary" with "Broken Sink"
  And I press "Submit Problem"
  Given I am on the problem submission page
  And I select "electronics" from "skills"
  And I fill in "Problem Summary" with "Broken TV"
  And I press "Submit Problem"
  When I go to the profile page
  Then I should see "Broken Sink"
  And I should see "Broken TV"
  And I should not see "Broken Pipe"