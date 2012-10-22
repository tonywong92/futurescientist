Feature: allow submission of problems

  As a Requester
  So that I can post a problem
  I want to be able to fill out and submit a problem form

Background: Go to the Problem Submission view
  Given I am on the home page
  When I follow "Submit New Problem"
  Then I should be on the problem submission page
  
Scenario: problem submission form renders correctly
  Given I am on the problem submission page
  Then I should see a "Name" text box
  Then I should see a "Phone Number" text box
  And I should see a "Location" text box
  And I should see a "Problem Summary" text box
  And I should see an optional "Description" text box
  
Scenario: Problem submits successfully
  Given I am on the problem submission page
  When I fill in "Location" with "Sproul Plaza"
  And I fill in "Name" with "James Won"
  And I fill in "Phone Number" with "999-999-9999"
  And I fill in "Price" with "$10"
  And I fill in "Problem Summary" with "Broken Sink"
  And I press "Submit"
  And I go to the Future Scientists home page
  Then I should see a problem with the description "Broken Sink"
