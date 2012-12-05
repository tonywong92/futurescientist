Feature: User can make an account and submit a skillset
    As a Provider,
    So that I can provide the required information,
    I want to able to make an account and submit my skillset.

Background:
    Given the site is set up
    And I am on the create account page
    Then I should see "Create New Account"

Scenario: Happy Path - User successfully creates an account and submits skills
    Given I add the "water" skill to the database
    And I go to the create account page
    When I fill in the following fields:
        | Email         | Account Name | Password | Name | Phone Number | Location |
        | test@test.com | Tester       | Password | Test | 1234567890   | Panama   |
    Then I should see "Water"
    And I check "water"
    And I press "Create Account"
    Then I should be on the problems page
    And I should not see "Tester"
		And I should see "You have successfully created an account"
    
Scenario: Happy Path - User successfully creates an account and doesn't submit skills
    When I fill in the following fields:
        | Email         | Account Name | Password | Name | Phone Number | Location |
        | test@test.com | Tester       | Password | Test | 1234567890   | Panama   |
    And I press "Create Account"
    Then I should be on the problems page
    And I should not see "Tester"
		When I login with "Tester" and "Password"
		Then I should be on the problems page
		And I should see "Tester"
    
Scenario: User tries to create an account with an existing account name
    When I fill in the following fields:
        | Email         | Account Name | Password | Name | Phone Number | Location |
        | test@test.com | Tester       | Password | Test | 1234567890   | Panama   |
    And I press "Create Account"
    And I am on the create account page
    And I fill in the following fields:
        | Email         | Account Name | Password | Name | Phone Number | Location |
        | test@test.com | Tester       | Password | Test | 1234567890   | Panama   |
    And I press "Create Account"
    Then I should see "Account name has already been taken"

Scenario Outline: User submits an invalid account creation form
    When I fill in "email" with "<Email>"
    And I fill in "account_name" with "<Account Name>"
    And I fill in "password" with "<Password>"
    And I fill in "name" with "<Name>"
    And I fill in "phone_number" with "<Phone Number>"
    And I fill in "location" with "<Location>"
    And I press "Create Account"
    Then I should see the "<Error Message>" error
    When I login with "<Account Name>" and "Password"
    Then I should see "No such account exists"

    Examples:
        | Email         | Account Name | Password | Name | Phone Number | Location | Error Message        |
        |               | Tester       | Password | Test | 1234567890   | Panama   | Missing Email        |
        | test@test.com |              | Password | Test | 1234567890   | Panama   | Missing Account Name |
        | test@test.com | Tester       |          | Test | 1234567890   | Panama   | Missing Password     |
        | test@test.com | Tester       | Password | Test |              | Panama   | Missing Phone Number |

        
    
