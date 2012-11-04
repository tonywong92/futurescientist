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
 # | Address2 | water           | broken water pipe |                   |
#  | Address3 | water, mold     | roof is leaking   | roof is leaking   |

  And I am on the home page
  
Scenario: successfully show only problems with the skill 'water'
  When I select "water" from "skills"
  And I press "problems_submit"
  Then I should see only "2" problems of "broken water pipe"

Scenario: successfully show all current existing problem's location and skills
  Then the "value" field within "select#address option:first" should contain "All2"
  And I should see "Address2" in "address"
  And I should see "Address3" in "address"
  And I should see "water" in "skills"
  And I should see "water, mold" in "skills"
  And I should see "All" in "address"
  And I should see "All" in "skills"
  
