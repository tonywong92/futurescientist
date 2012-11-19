Feature: Admin can make an admin account
    As an Admin,
    So that I can moderate the site,
    I want to be able to create an administrative account

Background:
    Given the site is set up
    And I am logged in as an admin
    And I am on the create account page
    Then I should see "Admin"

Scenario: Happy Path - Admin successfully creates an account
    Given I fill in the following fields:
        | Email               | Account Name | Password | Name  | Phone Number | Location |
        | admin@something.com | admin        | password | Admin | 123456789    | US       |
    And I check "Admin"
    And I press "Create Account"
    Then I should be on the problems page
    When I go to the profile page
    Then I should see "Admin"

Scenario: Verification of regular Provider's account
    Given I add the "water" skill to the database
    And I add the "electronics" skill to the database
    And I go to the create account page
    When I fill in the following fields:
        | Email                | Account Name | Password | Name | Phone Number | Location |
        | tester@something.com | Tester       | Password | Test | 123456789    | Panama   |
    Then I should see "Water"
    And I check "water"
    And I check "electronics"
    And I uncheck "Admin"
    And I press "Create Account"
    Then I should be on the problems page
    When I go to the skills verification page
    And I should see "water"
    And I should see "electronics"
    And I choose "water yes"
    And I choose "electronics yes"
    And I press "Verify Skill"
    Then I should be on the skills verification page
    And I should not see "water"
    And I should not see "electronics"
