Feature: Admin can make an admin account
    As an Admin,
    So that I can moderate the site,
    I want to be able to create an administrative account

Background:
    Given the site is set up
    And I am logged in as an admin
    And I am on the create account page
    Then I should see "admin"

Scenario: Happy Path - Admin successfully creates an account
    Given I fill in the following fields:
        | Email               | Account Name | Password | Name  | Phone Number | Location |
        | admin@something.com | admin        | password | Admin | 123456789    | US       |
    And I check "admin"
    And I press "Create Account"
    Then I should be on the problems page
    
Scenario: Admin tries to create an account with an existing account name
    When I fill in the following fields:
        | Email                | Account Name | Password | Name  | Phone Number | Location |
        | admin@something.com  | admin        | password | Admin | 123456789    | US       |
    And I check "admin"
    And I press "Create Account"
    And I am on the create account page
    And I fill in the following fields:
        | Email                | Account Name | Password | Name  | Phone Number | Location |
        | admin@something.com  | admin        | password | Admin | 123456789    | US       |
    And I check "admin"
    And I press "Create Account"
    Then I should see "Account name has already been taken"
    
Scenario Outline: Admin submits an invalid account creation form
    When I fill in "email" with "<Email>"
    And I fill in "account_name" with "<Account Name>"
    And I fill in "password" with "<Password>"
    And I fill in "name" with "<Name>"
    And I fill in "phone_number" with "<Phone Number>"
    And I fill in "location" with "<Location>"    
    And I check "admin"
    And I press "Create Account"
    Then I should be on the create account page
    Then I should see the "<Error Message>" error

    Examples:
        | Email               | Account Name | Password | Name  | Phone Number | Location | Error Message        |
        | admin@something.com |              | password | Admin | 123456789    | US       | Missing Account Name |
        | admin@something.com | admin        |          | Admin | 123456789    | US       | Missing Password     |
        | admin@something.com | admin        | password |       | 123456789    | US       | Missing Name         |   
        | admin@something.com | admin        | password | Admin |              | US       | Missing Phone Number |

