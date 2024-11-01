Feature: Time Slots Page
  As a user
  I want to view time slots for a schedule
  So that I can filter and find time slots by day and type

  Background:
    Given a schedule exists with the schedule name "Sched 1" and semester name "Fall 2024"
    And I am logged in as a user with first name "Test"
    And the following time slots exist:
      | day  | start_time | end_time | slot_type |
      | MWF  | 09:00      | 10:00    | LEC       |
      | MW   | 10:00      | 11:00    | LAB       |
      | TR   | 11:00      | 12:00    | LEC       |
      | F    | 13:00      | 14:00    | LEC       |

  Scenario: Viewing all time slots
    When I visit the time slots page for "Sched 1"
    Then I should see a time slot for "MWF" from "09:00" to "10:00" of type "LEC"
    And I should see a time slot for "MW" from "10:00" to "11:00" of type "LAB"
    And I should see a time slot for "TR" from "11:00" to "12:00" of type "LEC"
    And I should see a time slot for "F" from "13:00" to "14:00" of type "LEC"

  Scenario: Filtering time slots by day
    When I visit the time slots page for "Sched 1"
    And I select "MWF" from the "Filter by Day" dropdown
    And I click the "Filter" button
    Then I should see a time slot for "MWF" from "09:00" to "10:00" of type "LEC"
    And I should not see a time slot for "MW" from "10:00" to "11:00" of type "LAB"
    And I should not see a time slot for "TR" from "11:00" to "12:00" of type "LEC"

  Scenario: Filtering time slots by type
    When I visit the time slots page for "Sched 1"
    And I select "LAB" from the "Filter by Type" dropdown
    And I click the "Filter" button
    Then I should see a time slot for "MW" from "10:00" to "11:00" of type "LAB"
    And I should not see a time slot for "MWF" from "09:00" to "10:00" of type "LEC"
    And I should not see a time slot for "TR" from "11:00" to "12:00" of type "LEC"
    And I should not see a time slot for "F" from "13:00" to "14:00" of type "LEC"
