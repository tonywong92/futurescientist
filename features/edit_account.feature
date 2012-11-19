Feature: Edit accounts email/password

Scenario: Edit email (Happy Path)
        Given the site is set up
        And I am logged in as an admin
	And I am on the edit account page
	And I fill in "email_address" with "test@yahoo.com"
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
	Given the site is set up
	And I am logged in as an admin
	And I am on the edit account page
	And I fill in "password_current" with "Password"
	And I fill in "password_new_new" with "Foobarzz"
	And I fill in "reenter_pass" with "Foobarzz"
	And I press "Change Password"
	Then I should be on the edit account page
	And I should see "Password changed"

Scenario: Change password (sad path)
       Given the site is set up
       And I am logged in as an admin
       And I am on the edit account page
       And I fill in "password_current" with "foobar"
       And I fill in "password_new_new" with "Foobarzz"
       And I fill in "reenter_pass" with "Foobarzz"
       And I press "Change Password"
       Then I should be on the edit account page
       And I should see "Password incorrect"

Scenario: Change password (sad path 2)
	Given the site is set up
	And I am logged in as an admin
	And I am on the edit account page
	And I fill in "password_current" with "Password"
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

Scenario: Change Location (Happy Path)
	Given the site is set up
	And I am logged in as an admin
	And I am on the edit account page
	And I fill in "location_name" with "SF"
	And I press "Change Location"
	Then I should be on the edit account page
	And I should see "Location changed"

Scenario: Change Location (Sad Path - not logged in)
	Given I am on the edit account page
	And I fill in "location_name" with "SF"
	And I press "Change Location"
	Then I should be on the edit account page
	And I should see "You are not logged in"

Scenario: Change Phone Number (Happy Path)
	Given the site is set up
	And I am logged in as an admin
	And I am on the edit account page
	And I fill in "phone_number" with "4839458403"
	And I press "Change Phone"
	Then I should be on the edit account page
	And I should see "Phone number changed"

Scenario: Change Phone Number (Sad Path - Not logged in)
	And I am on the edit account page
	And I fill in "phone_number" with "4839458403"
	And I press "Change Phone"
	Then I should be on the edit account page
	And I should see "You are not logged in"

Scenario: Edit Skills (Happy Path - Regular user)
	Given I add the "water" skill to the database
	And the site is set up
	And I am logged in as an admin
	And I am on the edit account page
	And I check "water"
        And I press "Change Skills"
        Then I should be on the edit account page
        And I should see "Skills to be verified"

Scenario: Edit Skills (Sad Path - Not logged in)
	Given I add the "water" skill to the database
	And I am on the edit account page
	And I check "water"
        And I press "Change Skills"
        Then I should be on the edit account page
        And I should see "You are not logged in"
	



