Feature: Edit accounts skills/emails/phone numbers

Scenario: Add skill
		Given I am on the accounts page
		And I click "edit account"
		And I should be able to add a skill

Scenario: Delete skill
		Given I am on the accounts page
		And I click "edit account"
		And I should be able to delete a skill

Scenario: Update email
		Given I am on the accounts page
		And I click "change email"
		And I should be able to change my email

Scenario: Change Phone Number
		Given I am on the accounts page
		And I click "change phone number"
		And I should be able to chang emy phone number


