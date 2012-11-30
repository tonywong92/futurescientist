Feature: allow problems to be edited or deleted by the poster

 As a Requester,
 So that I can keep providers updated,
 I want to be able to edit or delete my post.

Background: problems have been created by some requester
  Given the site is set up
  And the following users exists:
  | name   | phone_number   | location   |
  | John   | 6264539999     | Address2   |

  And I add the "electronics" skill to the database
  And I add the "water" skill to the database
  And I add the "electricity" skill to the database
  Given I go to the create account page
  When I fill in the following fields:
        | Account Name | Password | Name | Phone Number | Location |
        | Tester       | password | Bob  | 6265559999   | Panama   |
    Then I should see "Water"
    And I check "water"
    And I press "Create Account"
    And I confirm through text
    And I press "Continue to problems index"
    Then I should be on the problems page
 
  Given "Bob" created the following problems:
  | location | skills          | summary           | description       | wage |
  | Address1 | water           | broken water pipe | water pipe broken | 50   | 
  | Address2 | electricity     | wire broken       |                   | 50   |
  | Address3 | electronics     | computer broken   | computer broken   | 50   |
  | Address3 | electronics     | gameboy broken    | gameboy broken    | 50   |
  | Address4 | electronics     | ps3 broken        | ps3 broken        | 50   |

  Given "John" created the following problems:
  | location | skills          | summary           | description       | wage |
  | Address3 | electricity     | outlet exploded   |                   | 50   |

  And I am on the home page
  When I login with "Tester" and "password"
  Given I am on the home page
  
Scenario: successfully edit and delete a problem that was created by the poster
  When I follow "broken water pipe"
  And I follow "Edit"
  Then I should see "water"
  When I select "electronics" from "skills"
  And I fill in "problem_summary" with "laptop broke"
  And I press "Update Problem"
  Then I should see "laptop broke was successfully updated."
  And I should see "electronics"
  When I press "Delete"
  Then I should see "Problem 'laptop broke' deleted."

Scenario: Only the poster of the problem may edit that problem
  When I follow "outlet exploded"
  Then I should not see "Edit"
