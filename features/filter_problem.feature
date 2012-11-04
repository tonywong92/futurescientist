Feature: Filtering Problems

As a Provider,
So that I can quickly find problems relevant to me,
I want to be able to filter them by skillset or region

Background: problems have been created by some requester

  Given the following users exists:
  | name   | phone_number   | location   |
  | Bob    | 6265559999     | Address1   |
  | John   | 6264539999     | Address2   |

  Given "Bob" created the following problems:
  | location | skills          | summary           | description       |
  | Address1 | water           | broken water pipe | water pipe broken |
  | Address2 | electricity     | wire broken       |                   |
  | Address3 | electronics     | computer broken   | computer broken   |
  | Address3 | electronics     | gameboy broken    | gameboy broken    |
  | Address4 | electronics     | ps3 broken        | ps3 broken        |
  | Address3 | electricity     | outlet exploded   |                   |

  And I am on the home page
  
Scenario: successfully show only problems with the skill 'water'
  When I select "water" from "skills"
  And I unselect "All" from "skills"
  And I press "problems_submit"
  Then I should see "broken water pipe"
  And I should not see "wire broken"
  And I should not see "computer broken"
  And I should not see "gameboy broken"
  And I should not see "ps3 broken"
  And I should not see "outlet exploded"

Scenario: successfully show only problems with the location 'Address1' and make sure preferences for filter is saved as I roam the site.
  When I select "Address2" from "address"
  And I unselect "All" from "address"
  And I press "problems_submit"
  Then I should not see "broken water pipe"
  And I should see "wire broken"
  And I should not see "computer broken"
  And I should not see "gameboy broken"
  And I should not see "ps3 broken"
  And I should not see "outlet exploded"
  When I follow "wire broken"
  And I follow "Back to problems list"
  Then I should not see "broken water pipe"
  And I should see "wire broken"
  And I should not see "computer broken"
  And I should not see "gameboy broken"
  And I should not see "ps3 broken"
  And I should not see "outlet exploded"

Scenario: successfully show only problems with the skill 'water' and location 'address3'
  When I select "electronics" from "skills"
  And I select "Address3" from "address"
  And I unselect "All" from "skills"
  And I unselect "All" from "address"
  And I press "problems_submit"
  Then I should not see "broken water pipe"
  And I should not see "wire broken"
  And I should see "computer broken"
  And I should see "gameboy broken"
  And I should not see "ps3 broken"
  And I should not see "outlet exploded"