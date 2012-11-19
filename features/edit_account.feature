Feature: Edit accounts email/password

<<<<<<< HEAD
Background:
  Given the site is set up
  And I am logged in as an admin
=======
Scenario: Edit email (Happy Path)
        Given the site is set up
        And I am logged in as an admin
>>>>>>> 13f661fa89afe1508d31830b20bd8461e7ec0441
	And I am on the edit account page

Scenario: Edit email
	When I fill in "email_address" with "test@yahoo.com"
	And I press "Update"
	Then I should be on the edit account page
  And I should see "Email changed!"

Scenario: Edit email (Sad Path)
	Given I am on the edit account page
	And I fill in "email_address" with "test@yahoo.com"
	And I press "Update"
	Then I should be on the edit account page
        And I should see "You are not logged in"

Scenario: Change password (Happy Path)
	When I fill in "password_current" with "Password"
	And I fill in "password_new_new" with "Foobarzz"
	And I fill in "reenter_pass" with "Foobarzz"
	And I press "Change Password"
	Then I should be on the edit account page
	And I should see "Password changed"

Scenario: Change password (sad path)
  When I fill in "password_current" with "foobar"
  And I fill in "password_new_new" with "Foobarzz"
  And I fill in "reenter_pass" with "Foobarzz"
  And I press "Change Password"
  Then I should be on the edit account page
  And I should see "Password incorrect"

Scenario: Change password (sad path 2)
	When I fill in "password_current" with "Password"
	And I fill in "password_new_new" with "Foobarzz"
	And I fill in "reenter_pass" with "LEEEajsjsjs"
	And I press "Change Password"
	Then I should be on the edit account page
	And I should see "The new password you entered doesn't match"

Scenario: Change password (sad path 3)
	Given I am on the edit account page
	And I fill in "password_current" with "Password"
	And I fill in "password_new_new" with "Foobarzz"
	And I fill in "reenter_pass" with "LEEEajsjsjs"
	And I press "Change Password"
	Then I should be on the edit account page
	And I should see "You are not logged in"

