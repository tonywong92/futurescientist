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