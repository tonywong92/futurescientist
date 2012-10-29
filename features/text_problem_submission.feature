Feature: User Problem Submission through text

As a user without web access,
So that I can still submit problems to the application,
I want to be able to send a text to submit a problem.

Scenario: Happy Path - User sends a text to submit a problem, and receives a confirmation text
  Given I send a text to "insert_phone#_here" with the required fields to "submit problem1"
  When "insert_phone#_here" opens the text message
  Then I should see "Problem confirmation" in the text message body
  When I go to the problems page
  Then I should see "problem1"

Scenario: Sad Path - User sends a text to submit a problem with missing fields, and receives a failure notification text
  Given I send a text to "insert_phone#_here" with missing fields to "submit problem1"
  When "insert_phone#_here" opens the text message
  Then I should see "error_message" in the text message body
  When I go to the problems page
  Then I should not see "problem1"