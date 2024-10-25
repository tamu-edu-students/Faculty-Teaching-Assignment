Feature: Google OAuth Authentication and Authorization

  Scenario: User logs in with Google OAuth successfully
    Given I am on the welcome page
    When I click the button "Sign in with Google"
    And I authorize access from Google
    Then I should be on my schedules page
    And I should see "You are logged in"

  Scenario: User logs out successfully
    Given I am logged in as a user
    When I click "Logout"
    Then I should be on the welcome page
    And I should see "You are logged out"
