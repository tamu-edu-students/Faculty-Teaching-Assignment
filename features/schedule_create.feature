Feature: Create a new schedule
  As a user
  I want to create a new schedule
  So that I can assign teachers to courses efficiently

  Scenario: Creating a schedule successfully
    Given I am logged in as a user with first name "Test"
    And I am on the new schedule page
    When I fill in "Schedule name" with "Fall 2024 Schedule"
    And I fill in "Semester name" with "Fall 2024"
    And I click the "Save Schedule" button
    Then I should see "Schedule was successfully created"
    And I should see "Fall 2024 Schedule"
    And I should see "Fall 2024"
