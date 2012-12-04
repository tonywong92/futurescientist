Feature: be able to see more information about problems

As a Provider,
So that I can understand more about the problem,
I want to be able to click on the problem to see more information.

Background: problems have been created by some requester
  Given the site is set up
  Given the following users exists:
  | name   | phone_number    | location   |
  | Bob    | +11234567890    | Address1   |
  | John   | +19994441111    | Address2   |
  And I add the "water, mold" skill to the database
  And I add the "water" skill to the database
  And I add the "electricity" skill to the database
  Given "Bob" created the following problems:
  | location | skills          | summary           | description       | wage |
  | Address1 | water           | broken water pipe | water pipe broken | 50   |
  | Address1 | electricity     | wire broken       | wire broken       | 50   |
  | Address3 | water, mold     | roof is leaking   | roof is leaking   | 50   |

  And I am on the home page
  
Scenario: successfully view a problem
  When I follow "broken water pipe"
  Then I should see "water pipe broken"

Scenario: successfully return to index page after viewing a problem
  When I follow "broken water pipe"
  And I follow "Back to problems list"