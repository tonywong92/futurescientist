Feature: allow submission of problems

  As a Requester
  So that I can post a problem
  I want to be able to fill out and submit a problem form

Background: Go to the Problem Submission view
  Given the site is set up
  Given I am on the home page
  When I follow "Submit New Problem"
  Then I should be on the problem submission page
  
Scenario: problem submission form renders correctly
  Given I am on the problem submission page
  Then I should see "Name"
  Then I should see "Phone Number"
  And I should see "Location"
  And I should see "Problem Summary"
  And I should see "Description"
  And I should see "Wage"
  
Scenario: Problem submits successfully
  Given I add the "water" skill to the database
  Given I am on the problem submission page
  When I fill in "Location" with "Sproul Plaza"
  And I fill in "Name" with "James Won"
  And I fill in "Phone Number" with "999-999-9999"
  And I select "water" from "skills"
  And I fill in "Problem Summary" with "Broken Sink"
  And I fill in "Wage" with "50"
  And I press "Submit Problem"
  And I go to the home page
  Then I should see "Broken Sink"

Scenario: Problem submission page should be prepopulated if logged in
  Given I am on the create account page
  When I fill in the following fields:
        | Account Name | Password | Name | Phone Number | Location |
        | Tester       | Password | Test | 123456789    | Panama   |
  And I press "Create Account"
  And I confirm through text
  And I press "Continue to problems index"
  And I go to the problem submission page
  Then I should see "Test"
  And I should see "123456789"
  And I should see "Panama"

