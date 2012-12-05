Feature: Admin can verify Provider's skills
    As an Admin,
    So that I can make sure Providers can actually help the Requesters,
    I want to be able to verify/approve Provider skills.

Background:
    Given the site is set up
    And I add the "water" skill to the database
    And I add the "electronics" skill to the database
    And I go to the create account page
    And I fill in the following fields:
        | Email         | Account Name | Password | Name | Phone Number | Location |
        | test@test.com | Tester       | Password | Test | 1234567890   | Panama   |
    And I check "water"
    And I check "electronics"
    And I press "Create Account"
    Then I should be on the problems page
    And I login with "Tester" and "Password"
    Given "Test" created the following problems:
        | location | skills          | summary           | description       | wage |
        | Address1 | water           | broken water pipe | water pipe broken | 50   |
    And I log out
    And I am logged in as an admin
    And I am on the create account page
    And I should see "Admin"

Scenario: Verification of Provider's skills (non-admin)
    Given I go to the skills verification page
    And I should see "water"
    And I choose "water yes"
    And I choose "electronics yes"
    And I press "Verify Skill"
    Then I should be on the skills verification page
    And I should not see "water"
    And I should not see "electronics"