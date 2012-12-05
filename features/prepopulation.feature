Feature: prepopulation of fields
  As a User,
  So that I can take advantage of having an account.
  I want to be able to see my information prepopulated when submitting a new problem.

Background: Go to the Problem Submission view
  Given the site is set up
  Given I am on the home page
  When I follow "Submit New Problem"
  Then I should be on the problem submission page
  Given I log out

Scenario: Problem submission page should be prepopulated if logged in
  Given I am on the create account page
  When I fill in the following fields:
        | Email         | Account Name | Password | Name | Phone Number | Location |
        | test@test.com | Tester       | Password | Test | 1234567890   | 94704    |
  And I press "Create Account"
  And I log out
  And I login with "Tester" and "Password"
  And I go to the problem submission page
  Then the "Name" field should contain "Test"
  And the "Phone Number" field should contain "\+11234567890"
  And the "Location" field should contain "94704"

