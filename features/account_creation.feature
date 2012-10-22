Feature: User can make an account and submit a skillset
    As a Provider,
    So that I can provide the required information,
    I want to able to make an account and submit my skillset.

Background:
    Given I am on the create account page
    Then I should see "Create New Account"

Scenario: Happy Path - User successfully creates an account and submits skills
    When I fill in the following fields:
        | Email                | Account Name | Password | Name | Phone Number | Location |
        | tester@something.com | Tester       | password | Test | 123456789    | Panama   |
    And I check "water"
    And I press "Create Account"
    Then I should be on the problems page
    When I click on "Log In"
    And I log in with email "tester@something.com" and password "password"
    Then I should be on the "List View Page"
    And I should be successfully logged in
    
Scenario: Happy Path - User successfully creates an account and doesn't submit skills
    When I fill in the following fields:
        | Email                | Account Name | Password | Name | Phone Number | Location |
        | tester@something.com | Tester       | password | Test | 123456789    | Panama   |
    And I press "Create Account"
    Then I should be on the problems page
    
Scenario: User tries to create an account with an existing account name
    When I fill in the following fields:
        | Email                | Account Name | Password | Name | Phone Number | Location |
        | tester@something.com | Tester       | password | Test | 123456789    | Panama   |
    And I press "Create Account"
    And I fill in the following fields:
        | Email                | Account Name | Password | Name | Phone Number | Location |
        | tester@something.com | Tester       | password | Test | 123456789    | Panama   |
    And I press "Create Account"
    Then I should see the "Account Already Exists" error
    
Scenario Outline: User submits an invalid account creation form
    When I fill in the "Email" field with <Email>
    And I fill in the "Account Name" field with <Account Name>
    And I fill in the "Password" field with <Password>
    And I fill in the "Name" field with <Name>
    And I fill in the "Phone Number" field with <Phone Number>
    And I fill in the "Location" field with <Location>
    And I press "Create Account"
    Then I should be on the "Account Creation Form"
    Then I should see the <Error Message> error

    Examples:
        | Email                | Account Name | Password | Name | Phone Number | Location | Error Message        |
        |                      | Tester       | password | Test | 123456789    | Panama   | Missing Email        |
        | tester@something.com |              | password | Test | 123456789    | Panama   | Missing Account Name |
        | tester@something.com | Tester       |          | Test | 123456789    | Panama   | Missing Password     |
        | tester@something.com | Tester       | password |      | 123456789    | Panama   | Missing Name         |   
        | tester@something.com | Tester       | password | Test |              | Panama   | Missing Phone Number |
        | tester@something.com | Tester       | password | Test | 123456789    |          | Missing Location     |
        | fail-email           | Tester       | password | Test | 123456789    | Panama   | Invalid Email        |


        
    