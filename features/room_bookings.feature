Feature: Rooms Page 

    Scenario: User should be able to see their room bookings
        Given I am logged in as a user with first name "Test"
        And a schedule exists with the schedule name "Sched 1" and semester name "Fall 2024" for user "Test"
        And the following rooms exist for schedule "Sched 1":
        | campus    | building_code | room_number | capacity | is_active | is_lab   | is_learning_studio    | is_lecture_hall   |
        | CS        | BLDG1         | 101         | 30       | true      | true     | true                  | true              |
        | GV        | BLDG2         | 102         | 50       | true      | true     | true                  | true              |
        | CS        | BLDG3         | 102         | 50       | false     | true     | true                  | true              |
        And the following time slots exist:
        | day       | start_time    | end_time      | slot_type     |
        | MWF       | 09:00         | 10:00         | LEC         |
        | MW        | 08:00         | 10:00         | LEC         |
        When I visit the room bookings page for "Sched 1"
        Then I should see "View Data"
        And I should see "09:00 - 10:00"
        And I should see "BLDG1 101"
    
    Scenario: User should be able to switch tabs between timeslots
        Given I am logged in as a user with first name "Test"
        And a schedule exists with the schedule name "Sched 1" and semester name "Fall 2024" for user "Test"
        And the following rooms exist for schedule "Sched 1":
        | campus    | building_code | room_number | capacity | is_active | is_lab   | is_learning_studio    | is_lecture_hall   |
        | CS        | BLDG1         | 101         | 30       | true      | true     | true                  | true              |
        | GV        | BLDG2         | 102         | 50       | true      | true     | true                  | true              |
        | CS        | BLDG3         | 102         | 50       | false     | true     | true                  | true              |
        And the following time slots exist:
        | day       | start_time    | end_time      | slot_type     |
        | MWF       | 09:00         | 10:00         | LEC         |
        | MW        | 08:00         | 10:00         | LEC         |
        When I visit the room bookings page for "Sched 1"
        And I click "MW"
        Then I should see "View Data"
        And I should see "08:00 - 10:00"
        And I should not see "09:00 - 10:00"
        And I should see "BLDG1 101"
    
    Scenario: User should see an appropriate message if no rooms exist
        Given I am logged in as a user with first name "Test"
        And a schedule exists with the schedule name "Sched 1" and semester name "Fall 2024" for user "Test"
        When I visit the room bookings page for "Sched 1"
        Then I should see "View Data"
        And I should not see "Generate Remaining"
        And I should see "No rooms added to this schedule, click on View Data to Add Rooms!"

    Scenario: User should be able to go back to the schedules page
        Given I am logged in as a user with first name "Test"
        And a schedule exists with the schedule name "Sched 1" and semester name "Fall 2024" for user "Test"
        When I visit the room bookings page for "Sched 1"
        Then I should see "Back to Schedules"
        When I click "Back to Schedules"
        Then I should be on the schedules page

    Scenario: User should be able to create a room booking
        Given I am logged in as a user with first name "Test"
        And a schedule exists with the schedule name "Sched 1" and semester name "Fall 2024" for user "Test"
        And the following rooms exist for schedule "Sched 1":
        | campus    | building_code | room_number | capacity | is_active | is_lab   | is_learning_studio    | is_lecture_hall   |
        | CS        | BLDG1         | 101         | 30       | true      | true     | true                  | true              |
        | GV        | BLDG2         | 102         | 50       | true      | true     | true                  | true              |
        | CS        | BLDG3         | 102         | 50       | false     | true     | true                  | true              |
        And the following time slots exist:
        | day       | start_time    | end_time      | slot_type     |
        | MWF       | 09:00         | 10:00         | LEC         |
        | MW        | 08:00         | 10:00         | LEC         |
        And the following courses and their sections exist for schedule "Sched 1":
        | course_number       | max_seats | lecture_type | num_labs         | sections      |
        | 110                 | 96        | F2F          | 4                | 100,101       |
        | 110                 | 96        | F2F          | 4                | 100     |
        | 111                 | 96        | F2F          | 4                | 100       |
        | 435/735/735D        | 135       | F2F          | 2                | 100      |
        When I visit the room bookings page for "Sched 1"
        And I book room "BLDG1" "101" in "MWF" for "09:00 - 10:00" with "100" for "110"
        Then I should see "Unlocked"
    
    Scenario: User should be able to delete a room booking
        Given I am logged in as a user with first name "Test"
        And a schedule exists with the schedule name "Sched 1" and semester name "Fall 2024" for user "Test"
        And the following rooms exist for schedule "Sched 1":
        | campus    | building_code | room_number | capacity | is_active | is_lab   | is_learning_studio    | is_lecture_hall   |
        | CS        | BLDG1         | 101         | 30       | true      | true     | true                  | true              |
        | GV        | BLDG2         | 102         | 50       | true      | true     | true                  | true              |
        | CS        | BLDG3         | 102         | 50       | false     | true     | true                  | true              |
        And the following time slots exist:
        | day       | start_time    | end_time      | slot_type     |
        | MWF       | 09:00         | 10:00         | LEC         |
        | MW        | 08:00         | 10:00         | LEC         |
        And the following courses and their sections exist for schedule "Sched 1":
        | course_number       | max_seats | lecture_type | num_labs         | sections      |
        | 110                 | 96        | F2F          | 4                | 100,101       |
        | 110                 | 96        | F2F          | 4                | 100     |
        | 111                 | 96        | F2F          | 4                | 100       |
        | 435/735/735D        | 135       | F2F          | 2                | 100      |
        When I visit the room bookings page for "Sched 1"
        And I book room "BLDG1" "101" in "MWF" for "09:00 - 10:00" with "100" for "110"
        And I click "Delete"
        Then I should not see "Unlocked"
    
    Scenario: User should be able to lock a room booking
        Given I am logged in as a user with first name "Test"
        And a schedule exists with the schedule name "Sched 1" and semester name "Fall 2024" for user "Test"
        And the following rooms exist for schedule "Sched 1":
        | campus    | building_code | room_number | capacity | is_active | is_lab   | is_learning_studio    | is_lecture_hall   |
        | CS        | BLDG1         | 101         | 30       | true      | true     | true                  | true              |
        | GV        | BLDG2         | 102         | 50       | true      | true     | true                  | true              |
        | CS        | BLDG3         | 102         | 50       | false     | true     | true                  | true              |
        And the following time slots exist:
        | day       | start_time    | end_time      | slot_type     |
        | MWF       | 09:00         | 10:00         | LEC         |
        | MW        | 08:00         | 10:00         | LEC         |
        And the following courses and their sections exist for schedule "Sched 1":
        | course_number       | max_seats | lecture_type | num_labs         | sections      |
        | 110                 | 96        | F2F          | 4                | 100,101       |
        | 110                 | 96        | F2F          | 4                | 100     |
        | 111                 | 96        | F2F          | 4                | 100       |
        | 435/735/735D        | 135       | F2F          | 2                | 100      |
        When I visit the room bookings page for "Sched 1"
        And I book room "BLDG1" "101" in "MWF" for "09:00 - 10:00" with "100" for "110"
        And I click "Unlocked"
        Then I should not see "Unlocked"
        And I should see "Locked"

    Scenario: User should be able to assign instructors to a room booking
        Given I am logged in as a user with first name "Test"
        And a schedule exists with the schedule name "Sched 1" and semester name "Fall 2024" for user "Test"
        And the following rooms exist for schedule "Sched 1":
        | campus    | building_code | room_number | capacity | is_active | is_lab   | is_learning_studio    | is_lecture_hall   |
        | CS        | BLDG1         | 101         | 30       | true      | true     | true                  | true              |
        | GV        | BLDG2         | 102         | 50       | true      | true     | true                  | true              |
        | CS        | BLDG3         | 102         | 50       | false     | true     | true                  | true              |
        And the following time slots exist:
        | day       | start_time    | end_time      | slot_type     |
        | MWF       | 09:00         | 10:00         | LEC         |
        | MW        | 08:00         | 10:00         | LEC         |
        And the following courses and their sections exist for schedule "Sched 1":
        | course_number       | max_seats | lecture_type | num_labs         | sections      |
        | 110                 | 96        | F2F          | 4                | 100,101       |
        | 110                 | 96        | F2F          | 4                | 100     |
        | 111                 | 96        | F2F          | 4                | 100       |
        | 435/735/735D        | 135       | F2F          | 2                | 100      |
        And the following instructors exist for schedule "Sched 1":
        | id_number | first_name | last_name | middle_name | email            | before_9    | after_3  | beaware_of | max_course_load
        | 1001      | John       | Doe       | A           | john@example.com | true        | false    | test       | 1
        | 1002      | Jane       | Smith     | B           | jane@example.com | false       | false    |            | 1
        When I visit the room bookings page for "Sched 1"
        And I book room "BLDG1" "101" in "MWF" for "09:00 - 10:00" with "100" for "110"
        Then I should see "Unlocked"
        When I assign "John" to "BLDG1" "101" in "MWF" for "09:00 - 10:00" with "100" for "110"
        Then I should see "John"

  Scenario: User should not be able to override locked slots
        Given I am logged in as a user with first name "Test"
        And a schedule exists with the schedule name "Sched 1" and semester name "Fall 2024" for user "Test"
        And the following rooms exist for schedule "Sched 1":
        | campus    | building_code | room_number | capacity | is_active | is_lab   | is_learning_studio    | is_lecture_hall   |
        | CS        | BLDG1         | 101         | 30       | true      | true     | true                  | true              |
        | GV        | BLDG2         | 102         | 50       | true      | true     | true                  | true              |
        | CS        | BLDG3         | 102         | 50       | false     | true     | true                  | true              |
        And the following time slots exist:
        | day       | start_time    | end_time      | slot_type     |
        | MWF       | 09:00         | 10:00         | LEC         |
        | MW        | 08:00         | 10:00         | LEC         |
        And the following courses and their sections exist for schedule "Sched 1":
        | course_number       | max_seats | lecture_type | num_labs         | sections      |
        | 110                 | 96        | F2F          | 4                | 100,101       |
        | 110                 | 96        | F2F          | 4                | 100     |
        | 111                 | 96        | F2F          | 4                | 100       |
        | 435/735/735D        | 135       | F2F          | 2                | 100      |
        And the following instructors exist for schedule "Sched 1":
        | id_number | first_name | last_name | middle_name | email            | before_9    | after_3  | beaware_of | max_course_load 
        | 1001      | John       | Doe       | A           | john@example.com | true        | false    | test       | 1
        | 1002      | Jane       | Smith     | B           | jane@example.com | false       | false    |            | 1
        When I visit the room bookings page for "Sched 1"
        And I book room "BLDG1" "101" in "MWF" for "09:00 - 10:00" with "100" for "110"
        And I click "Unlocked"
        And I book room "BLDG1" "101" in "MWF" for "09:00 - 10:00" with "101" for "110"
        Then I should see "Locked Room Bookings Cannot be updated."

  Scenario: User should not be able blocked slots
        Given I am logged in as a user with first name "Test"
        And a schedule exists with the schedule name "Sched 1" and semester name "Fall 2024" for user "Test"
        And the following rooms exist for schedule "Sched 1":
        | campus    | building_code | room_number | capacity | is_active | is_lab   | is_learning_studio    | is_lecture_hall   |
        | CS        | BLDG1         | 101         | 30       | true      | true     | true                  | true              |
        | GV        | BLDG2         | 102         | 50       | true      | true     | true                  | true              |
        | CS        | BLDG3         | 102         | 50       | false     | true     | true                  | true              |
        And the following time slots exist:
        | day       | start_time    | end_time      | slot_type     |
        | MWF       | 09:00         | 10:00         | LEC         |
        | MW        | 08:00         | 10:00         | LEC         |
        And the following courses and their sections exist for schedule "Sched 1":
        | course_number       | max_seats | lecture_type | num_labs         | sections      |
        | 110                 | 96        | F2F          | 4                | 100,101       |
        | 110                 | 96        | F2F          | 4                | 100     |
        | 111                 | 96        | F2F          | 4                | 100       |
        | 435/735/735D        | 135       | F2F          | 2                | 100      |
        And the following instructors exist for schedule "Sched 1":
        | id_number | first_name | last_name | middle_name | email            | before_9    | after_3  | beaware_of | max_course_load 
        | 1001      | John       | Doe       | A           | john@example.com | true        | false    | test       | 1
        | 1002      | Jane       | Smith     | B           | jane@example.com | false       | false    |            | 1
        When I visit the room bookings page for "Sched 1"
        And I toggle availability for the room booking in "BLDG1" "101" at "09:00"
        And I book room "BLDG1" "101" in "MWF" for "09:00 - 10:00" with "100" for "110"
        Then I should see "Cannot assign to a blocked room."

  Scenario: User should be able to export room bookings to CSV
    Given I am logged in as a user with first name "Test"
    And a schedule exists with the schedule name "Sched 1" and semester name "Fall 2024" for user "Test"
    And the following rooms exist for schedule "Sched 1":
      | campus | building_code | room_number | capacity | is_active | is_lab | is_learning_studio | is_lecture_hall |
      | CS     | BLDG1         | 101         | 30       | true      | true   | true               | true            |
      | GV     | BLDG2         | 102         | 50       | true      | true   | true               | true            |
    And the following time slots exist:
      | day | start_time | end_time | slot_type |
      | MWF | 09:00      | 10:00    | LEC       |
      | MW  | 08:00      | 10:00    | LEC       |
    And the following courses and their sections exist for schedule "Sched 1":
        | course_number       | max_seats | lecture_type | num_labs         | sections      |
        | 110                 | 96        | F2F          | 4                | 100,101       |
        | 110                 | 96        | F2F          | 4                | 100     |
        | 111                 | 96        | F2F          | 4                | 100       |
        | 435/735/735D        | 135       | F2F          | 2                | 100      |
    And the following room bookings exist:
      | building_code | room_number | day | start_time | end_time | course_number | section_number | first_name | last_name |
      | BLDG1         | 101         | MWF | 09:00      | 10:00    | 110           | 100            | John       | Doe       |
    When I visit the rooms page for "Sched 1"
    Then I should see "Export"
    When I click "Export"
    Then I should receive a CSV file with the filename "room_bookings.csv"
    And the CSV file should contain the following headers:
      | MWF                 | BLDG1 101 (Seats: 30) | BLDG2 102 (Seats: 50) |
    And the CSV file should contain the following rows:
      | 09:00 - 10:00       | 110 - 100 - John Doe  |                        |

    Scenario: User receives a schedule using feasible data 
      Given I am logged in as a user with first name "Test"
      And a schedule exists with the schedule name "Sched 1" and semester name "Fall 2024" for user "Test"
      And the following rooms exist for schedule "Sched 1":
        | campus    | building_code | room_number | capacity | is_active | is_lab   | is_learning_studio    | is_lecture_hall   |
        | CS        | BLDG1         | 101         | 30       | true      | true     | true                  | true              |
        | CS        | BLDG2         | 102         | 50       | true      | true     | true                  | true              |
      And the following time slots exist:
        | day       | start_time    | end_time      | slot_type     |
        | MWF       | 09:00         | 10:00         | LEC         |
        | TR        | 08:00         | 10:00         | LEC         |
      And the following courses and their sections exist for schedule "Sched 1":
        | course_number       | max_seats | lecture_type | num_labs         | sections      |
        | 110                 | 50        | F2F          | 4                | 100,101       |
        | 111                 | 25        | F2F          | 4                | 100           |
      And the following instructors exist for schedule "Sched 1":
        | id_number | first_name | last_name | middle_name | email            | before_9    | after_3  | beaware_of | max_course_load 
        | 1001      | John       | Doe       | A           | john@example.com | true        | false    | test       | 1
        | 1002      | Jane       | Smith     | B           | jane@example.com | true        | false    |            | 1
      When I visit the room bookings page for "Sched 1"
      Then I should see "Generate Remaining"
      When I click the "Generate Remaining" button
      Then I should see "Schedule generated"

    Scenario: User can see that schedule dissatisfies a professor
      Given I am logged in as a user with first name "Test"
      And a schedule exists with the schedule name "Sched 1" and semester name "Fall 2024" for user "Test"
      And the following rooms exist for schedule "Sched 1":
        | campus    | building_code | room_number | capacity | is_active | is_lab   | is_learning_studio    | is_lecture_hall   |
        | CS        | BLDG1         | 101         | 30       | true      | true     | true                  | true              |
        | CS        | BLDG2         | 102         | 50       | true      | true     | true                  | true              |
      And the following time slots exist:
        | day       | start_time    | end_time      | slot_type     |
        | MWF       | 09:00         | 10:00         | LEC         |
        | MW        | 09:00         | 10:00         | LEC         |
        | TR        | 08:00         | 10:00         | LEC         |
      And the following courses and their sections exist for schedule "Sched 1":
        | course_number       | max_seats | lecture_type | num_labs         | sections      |
        | 110                 | 50        | F2F          | 4                | 100,101       |
        | 111                 | 25        | F2F          | 4                | 100           |
      And the following instructors exist for schedule "Sched 1":
        | id_number | first_name | last_name | middle_name | email            | before_9    | after_3  | beaware_of | max_course_load 
        | 1001      | John       | Doe       | A           | john@example.com | false       | false    | test       | 3
        | 1002      | Jane       | Smith     | B           | jane@example.com | true        | false    |            | 2
      When I visit the room bookings page for "Sched 1"
      Then I should see "Generate Remaining"
      When I click the "Generate Remaining" button
      Then I should see "Schedule generated"

    Scenario: User receives an error when schedule is infeasible
      Given I am logged in as a user with first name "Test"
      And a schedule exists with the schedule name "Sched 1" and semester name "Fall 2024" for user "Test"
      And the following rooms exist for schedule "Sched 1":
        | campus    | building_code | room_number | capacity | is_active | is_lab   | is_learning_studio    | is_lecture_hall   |
        | CS        | BLDG1         | 101         | 30       | true      | true     | true                  | true              |
      And the following time slots exist:
        | day       | start_time    | end_time      | slot_type     |
        | MWF       | 09:00         | 10:00         | LEC         |
      And the following courses and their sections exist for schedule "Sched 1":
        | course_number       | max_seats | lecture_type | num_labs         | sections      |
        | 110                 | 20        | F2F          | 4                | 100,101       |
        | 111                 | 30        | F2F          | 4                | 100           |
      And the following instructors exist for schedule "Sched 1":
        | id_number | first_name | last_name | middle_name | email            | before_9    | after_3  | beaware_of | max_course_load 
        | 1001      | John       | Doe       | A           | john@example.com | false       | false    | test       | 1
        | 1002      | Jane       | Smith     | B           | jane@example.com | true        | false    |            | 1
      When I visit the room bookings page for "Sched 1"
      Then I should see "Generate Remaining"
      When I click the "Generate Remaining" button
      Then I should see "Solution infeasible!"