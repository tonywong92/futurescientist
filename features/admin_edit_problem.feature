Feature: Admin can edit/delete problems
    As an Admin,
    So that I can enforce rules in postings and prevent spam,
    I want to be able to edit/delete posts.

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

Scenario: Admin can edit or delete problems
    Given I am on the problems page
    When I follow "broken water pipe"
    Then I should see "Edit"
    And I press "Delete"
    Then I should see "Problem 'broken water pipe' deleted."
