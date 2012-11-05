Feature: Edit accounts skills/emails/phone numbers

Background: Accounts have been created

Given the following account exists:
  | account_name   | email            | password |
  | foobar         | foobar@yahoo.com | lalala   |

Scenario: Edit email
	Given I am on the edit account page
	And I fill in "email_address" with "test@yahoo.com"
	And I press "Update"
	Then I should be on the edit account page
