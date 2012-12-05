Feature: User can login and logout
    As a User,
    So that I can use my account,
    I want to be able to login and logout successfully.

Background:
    Given the site is set up
    And I am on the create account page
    Then I should see "Create New Account"
    
Scenario: User tries to logout
    When I fill in the following fields:
        | Email         | Account Name | Password | Name | Phone Number | Location |
        | test@test.com | Tester       | Password | Test | 1234567890   | Panama   |
    And I press "Create Account"
    Then I should be on the problems page
    And I should not see "Tester"
    When I login with "Tester" and "password"
    Then I should see "Your password is incorrect"
    When I login with "Tester" and "Password"
    And I log out
    Then I should see "You have successfully logged out"

Scenario: User tries to login with wrong id or password
    When I login with "Runner" and "Nike"
    Then I should see "No such account exists"
    
