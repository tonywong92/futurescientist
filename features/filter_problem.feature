Feature: Filtering Problems

As a Provider,
So that I can quickly find problems relevant to me,
I want to be able to filter them by skillset

Background: problems have been created by some requester

  Given the following problems exists:
  | name | location | skills relevant | problem summary   | description       |
  | Bob  | Address1 | water           | broken water pipe | water pipe broken |
  | John | Address2 | water           | broken water pipe |                   |
  | Bob  | Address1 | electricity     | wire broken       | wire broken       |
  | Bob  | Address3 | water, mold     | roof is leaking   | roof is leaking   |

  And I am logged in as Bob
  And I add the "water" skill to the database
  And I am on the FutureScientists home page
  
Scenario: successfully show only problems with the skill 'water'
  When I click on the dropdown menu
  And I select "water"
  Then I should see only "two" problems of "broken water pipe"

Scenario: 
  When I click on the dropdown menu
  Then "water" should show up
  And "All" should show up
