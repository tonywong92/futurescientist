Feature: Admin can make an admin account
    As an Admin,
    So that I can moderate the site,
    I want to be able to create an administrative account

Background:
    Given the site is set up
    And I add the "water" skill to the database
    And I add the "electronics" skill to the database
    And I go to the create account page
    And I fill in the following fields:
        | Account Name | Password | Name | Phone Number | Location |
        | Tester       | Password | Test | 123456789    | Panama   |
    And I check "water"
    And I check "electronics"
    And I uncheck "admin"
    And I press "Create Account"
    And I confirm through text
    And I press "Continue to problems index"
    Then I should be on the problems page
    And I login with "Tester" and "Password"
    Given "Test" created the following problems:
        | location | skills          | summary           | description       |
        | Address1 | water           | broken water pipe | water pipe broken |
    And I log out
    And I am logged in as an admin
    And I am on the create account page
    And I should see "Admin"

Scenario: Happy Path - Admin successfully creates an account
    Given I fill in the following fields:
        | Account Name | Password | Name  | Phone Number | Location |
        | admin        | password | Admin | 123456789    | US       |
    And I check "Admin"
    And I press "Create Account"
    And I confirm through text
    And I press "Continue to problems index"
    Then I should be on the problems page
    When I go to the profile page
    Then I should see "Admin"

Scenario: Verification of regular Provider's account   
    Given I go to the skills verification page
    And I should see "water"
    And I choose "water yes"
    And I choose "electronics yes"
    And I press "Verify Skill"
    Then I should be on the skills verification page
    And I should not see "water"
    And I should not see "electronics"

Scenario: Admin can edit or delete problems
    Given I am on the problems page
    When I follow "broken water pipe"
    Then I should see "Edit"
    And I press "Delete"
    Then I should see "Problem 'broken water pipe' deleted."

Scenario: Admin should be able to add new skills
    Given I am on the problems page
    And I follow "master"
    And I follow "Add a New Skill"
    And I fill in "skill" with "Landscaping"
    And I press "Add"
    When I go to the create account page
    Then I should see "Landscaping"
