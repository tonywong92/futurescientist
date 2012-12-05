Feature: Provider can accept a Problem
  As a Provider,
  So that I can accept problems through the website,
  I want to be given an option to do so on the problem details page, and for myself and the Requester to be notified through text after I do so.
  
Background:
  Given the site is set up
  And I add the "water" skill to the database
  And I add the "electricity" skill to the database
  And "Bob" created the following problems:
  | location | skills          | summary           | description       | wage |
  | Address1 | water           | broken water pipe | water pipe broken | 50   | 
  | Address2 | electricity     | wire broken       |                   | 50   |
  | Address3 | water           | computer broken   | computer broken   | 50   |
  | Address3 | electricity     | gameboy broken    | gameboy broken    | 50   |
  | Address4 | electricity     | ps3 broken        | ps3 broken        | 50   |
  
Scenario: Happy Path - A qualified provider accepts a problem, and the problem is removed from index
  Given I have created the following "water" provider accounts with the following fields:
    | Email          | Account Name | Password | Name | Phone Number | Location |
    | test@tester.com| Tester       | Password | Test | 1234567890   | Panama   |
  And I login with "Tester" and "Password"
  Then I should see "Tester"
  And I should be on the problems page
  When I go to the problem details page for the first problem
  And I follow "accept_problem"
  Then I should be on the problems page
  And I should not see "Address1"
  
Scenario: Sad Path - An unqualified provider accepts a problem
  Given I go to the create account page
  And I fill in the following fields:
    | Email         | Account Name | Password | Name | Phone Number | Location |
    | test@test.com | Tester       | Password | Test | 1234567890   | Panama   |
  And I check "water"
  And I press "Create Account"
  When I click on the first available "water" problem
  Then I should be on the problem details page
  Then I should not see "Accept this problem"
  
  Scenario: Sad Path - A provider qualified for the wrong skill accepts a problem
  Given I have created a "electricity" provider account with the following fields:
    | Account Name | Password | Name | Phone Number | Location |
    | Tester       | Password | Test | 1234567890   | Panama   |
  And I am on the problems page
  When I click on the first available "water" problem
  Then I should be on the problem details page
  When I click on "Accept this problem"
  Then I should be on the problem acceptance confirmation page
  When I press "Continue to problems index"
  Then I should be on the problems page
  And there should be no remaining problems