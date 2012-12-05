Feature: Admin can add new skills
    As an Admin,
    So that I can update the application with new skills,
    I want to be able to add new skills through the dashboard.

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

Scenario: Admin should be able to add new skills
    Given I am on the problems page
    And I follow "master"
    And I follow "Add a New Skill"
    And I fill in "skill" with "Landscaping"
    And I press "Add"
    When I go to the create account page
    Then I should see "Landscaping"
