Feature: Delete a schedule
  As a user
  I want to delete a schedule I don't want
  So that I can remove it from the system

  Scenario: Deleting a schedule successfully
    Given I am logged in as a user with first name "Test"
    And I have created a schedule called "Fall 2024 Schedule"
    And I am on the schedules index page
    When I click the "Delete" button for "Fall 2024 Schedule"
    Then I should see "Schedule was successfully deleted"
    And I should not see "Fall 2024 Schedule"
