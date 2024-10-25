Feature: Welcome Page

  Scenario: Logged-in user is redirected to their schedules page
    Given I am logged in as a user with first name "Test"
    When I visit the welcome page
    Then I should be on my schedules page