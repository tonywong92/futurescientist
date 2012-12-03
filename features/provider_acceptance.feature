Feature: Provider can accept a Problem
  As a provider,
  So that I can accept problems through the website,
  I want to be given an option to do so on the problem details page, and for myself and the requester to be notified through text after I do so.
  
Background:
  Given the site is set up
  And I add the "water" skill to the database
  And I add the "electricity" skill to the database
  And I create a "water" problem
  
Scenario: Happy Path - A qualified provider accepts a problem, and the problem is removed from index
  Given I have created a "water" provider account with the following fields:
    | Account Name | Password | Name | Phone Number | Location |
    | Tester       | Password | Test | 123456789    | Panama   |
  And I am on the problems page
  When I click on the first available "water" problem
  Then I should be on the problem details page
  When I click on "Accept this problem"
  Then I should be on the problem acceptance confirmation page
  When I press "Continue to problems index"
  Then I should be on the problems page
  And there should be no remaining problems
  
Scenario: Sad Path - An unqualified provider accepts a problem
  Given I go to the create account page
  And I fill in the following fields:
    | Account Name | Password | Name | Phone Number | Location |
    | Tester       | Password | Test | 123456789    | Panama   |
  And I check "water"
  And I press "Create Account"
  And I confirm through text
  And I press "Continue to problems index"
  When I click on the first available "water" problem
  Then I should be on the problem details page
  When I click on "Accept this problem"
  Then I should see "Sorry, you are not yet qualified to accept this problem
  
  Scenario: Sad Path - A provider qualified for the wrong skill accepts a problem
  Given I have created a "electricity" provider account with the following fields:
    | Account Name | Password | Name | Phone Number | Location |
    | Tester       | Password | Test | 123456789    | Panama   |
  And I am on the problems page
  When I click on the first available "water" problem
  Then I should be on the problem details page
  When I click on "Accept this problem"
  Then I should be on the problem acceptance confirmation page
  When I press "Continue to problems index"
  Then I should be on the problems page
  And there should be no remaining problems