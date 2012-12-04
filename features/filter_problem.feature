Feature: Filtering Problems

As a Provider,
So that I can quickly find problems relevant to me,
I want to be able to filter them by skillset or region

Background: problems have been created by some requester
  Given the site is set up
  Given the following users exists:
  | name   | phone_number     | location   |
  | Bob    | +11234567890     | Address1   |
  | John   | +19994441111     | Address2   |

  And I add the "electronics" skill to the database
  And I add the "water" skill to the database
  And I add the "electricity" skill to the database

  Given "Bob" created the following problems:
  | location | skills          | summary           | description       | wage |
  | Address1 | water           | broken water pipe | water pipe broken | 50   |
  | Address2 | electricity     | wire broken       |                   | 50   |
  | Address3 | electronics     | computer broken   | computer broken   | 50   |
  | Address3 | electronics     | gameboy broken    | gameboy broken    | 50   |
  | Address4 | electronics     | ps3 broken        | ps3 broken        | 50   |
  | Address3 | electricity     | outlet exploded   |                   | 50   |

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
  When I select "address2" from "address"
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
  And I select "address3" from "address"
  And I unselect "All" from "skills"
  And I unselect "All" from "address"
  And I press "problems_submit"
  Then I should not see "broken water pipe"
  And I should not see "wire broken"
  And I should see "computer broken"
  And I should see "gameboy broken"
  And I should not see "ps3 broken"
  And I should not see "outlet exploded"