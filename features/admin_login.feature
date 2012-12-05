Feature: Admin can stay logged in
    As an Admin
    So that I can continue to use my account privileges,
    I want to stay logged in after creating another account.

Background:
    Given the site is set up
    And I am on the create account page
    Then I should see "Create New Account"

Scenario: If you are an admin, when you create another account, you should stay logged in as yourself
    Given I login with "master" and "Password"
    And I go to the profile page
    And I follow "Add Admin Account"
    When I fill in the following fields:
        | Email                | Account Name | Password | Name | Phone Number | Location |
        | tester@something.com | Tester       | Password | Test | 1234567890   | Panama   |
    And I press "Create Account"
    And I am on the problems page
    And I should see "master"
    And I should not see "Tester"     
    
