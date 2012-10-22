Feature: be able to see more information about problems

As a Provider,
So that I can understand more about the problem,
I want to be able to click on the problem to see more information.

Background: problems have been created by some requester
  
  Given the following users exists:
  | name   | phone_number   | location   |
  | Bob    | 6265559999     | Address1   |
  | John   | 6264539999     | Address2   |

  Given "Bob" created the following problems:
  | location | skills          | summary           | description       |
  | Address1 | water           | broken water pipe | water pipe broken |
  | Address1 | electricity     | wire broken       | wire broken       |
  | Address3 | water, mold     | roof is leaking   | roof is leaking   |

  And I am on the home page
  
Scenario: successfully view a problem
  When I follow "broken water pipe"
  Then I should see "water pipe broken"

Scenario: successfully return to index page after viewing a problem
  When I follow "broken water pipe"
  And I follow "Back to problems list"