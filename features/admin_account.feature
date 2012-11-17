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

Scenario: Verification of regular Provider's account
    Given I fill in the following fields:
        | Email               | Account Name | Password | Name  | Phone Number | Location |
        | water@something.com | water        | password | Water | 123456789    | US       |
    And I check "Water"
    And I press "Create Account"
    Then I should be on the problems page
    When I go to the skill approval page
    And I press "Approve"
    Then I should be on the skill approval page
    When I log out
    And I login with "water" and "password"
    And I go to a problem with "Water" skill
    Then I should be able to accept this problem