Feature: User can make an account and submit a skillset
    As a Provider,
    So that I can provide the required information,
    I want to able to make an account and submit my skillset.

Background:
    Given the site is set up
    And I log out
    And I am on the create account page
    Then I should see "Create New Account"

Scenario: Happy Path - User successfully creates an account and submits skills
    Given I add the "water" skill to the database
    And I go to the create account page
    When I fill in the following fields:
        | Account Name | Password | Name | Phone Number | Location |
        | Tester       | Password | Test | 123456789    | Panama   |
    Then I should see "Water"
    And I check "water"
    And I press "Create Account"
    Then I should be on the text confirmation page
    When I confirm through text
    And I press "Continue to problems index"
    Then I should be on the problems page
    And I should see "Tester"
    
Scenario: Happy Path - User successfully creates an account and doesn't submit skills
    When I fill in the following fields:
        | Account Name | Password | Name | Phone Number | Location |
        | Tester       | Password | Test | 123456789    | Panama   |
    And I press "Create Account"
    Then I should be on the text confirmation page
    When I confirm through text
    And I press "Continue to problems index"
    Then I should be on the problems page
    And I should see "Tester"
    
Scenario: User tries to logout
    When I fill in the following fields:
        | Account Name | Password | Name | Phone Number | Location |
        | Tester       | Password | Test | 123456789    | Panama   |
    And I press "Create Account"
    And I confirm through text
    And I press "Continue to problems index"
    Then I should be on the problems page
    And I should see "Tester"
    When I login with "Tester" and "password"
    Then I should see "Your password is incorrect"
    When I login with "Tester" and "Password"
    And I log out
    Then I should see "You have successfully logged out"
    
Scenario: User tries to create an account with an existing account name
    When I fill in the following fields:
        | Account Name | Password | Name | Phone Number | Location |
        | Tester       | Password | Test | 123456789    | Panama   |
    And I press "Create Account"
    And I am on the create account page
    And I fill in the following fields:
        | Account Name | Password | Name | Phone Number | Location |
        | Tester       | Password | Test | 123456789    | Panama   |
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
    Then I should be on the create account page
    Then I should see the "<Error Message>" error
    When I login with "<Account Name>" and "Password"
    Then I should see "No such account exists"

    Examples:
        | Account Name | Password | Name | Phone Number | Location | Error Message        |
        |              | Password | Test | 123456789    | Panama   | Missing Account Name |
        | Tester       |          | Test | 123456789    | Panama   | Missing Password     |
        | Tester       | Password | Test |              | Panama   | Missing Phone Number |

Scenario: User tries to login with wrong id or password
    When I login with "Runner" and "Nike"
    Then I should see "No such account exists"

Scenario: If you are an admin, when you create another account, you should stay logged in as yourself
    Given I login with "master" and "Password"
    And I go to the profile page
    And I follow "Add Admin Account"
    When I fill in the following fields:
        | Email                | Account Name | Password | Name | Phone Number | Location |
        | tester@something.com | Tester       | Password | Test | 123456789    | Panama   |
    And I press "Create Account"
    And I am on the problems page
    And I should see "master"
    And I should not see "Tester"


        
    
