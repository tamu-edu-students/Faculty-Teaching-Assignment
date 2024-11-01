Feature: Rooms Page 

    Scenario: User should be able to see their room bookings
        Given I am logged in as a user with first name "Test"
        And a schedule exists with the schedule name "Sched 1" and semester name "Fall 2024"
        And the following rooms exist for that schedule:
        | campus    | building_code | room_number | capacity | is_active | is_lab   | is_learning_studio    | is_lecture_hall   |
        | CS        | BLDG1         | 101         | 30       | true      | true     | true                  | true              |
        | GV        | BLDG2         | 102         | 50       | true      | true     | true                  | true              |
        | CS        | BLDG3         | 102         | 50       | false     | true     | true                  | true              |
        And the following time slots exist for that schedule:
        | day       | start_time    | end_time      | slot_type     |
        | MWF       | 09:00         | 10:00         | "LEC"         |
        | MW        | 08:00         | 10:00         | "LEC"         |
        When I visit the room bookings page for "Sched 1"
        Then I should see "View Data"
        And I should see "09:00 - 10:00"
        And I should see "BLDG1 101"
    
    Scenario: User should be able to switch tabs between timeslots
        Given I am logged in as a user with first name "Test"
        And a schedule exists with the schedule name "Sched 1" and semester name "Fall 2024"
        And the following rooms exist for that schedule:
        | campus    | building_code | room_number | capacity | is_active | is_lab   | is_learning_studio    | is_lecture_hall   |
        | CS        | BLDG1         | 101         | 30       | true      | true     | true                  | true              |
        | GV        | BLDG2         | 102         | 50       | true      | true     | true                  | true              |
        | CS        | BLDG3         | 102         | 50       | false     | true     | true                  | true              |
        And the following time slots exist for that schedule:
        | day       | start_time    | end_time      | slot_type     |
        | MWF       | 09:00         | 10:00         | "LEC"         |
        | MW        | 08:00         | 10:00         | "LEC"         |
        When I visit the room bookings page for "Sched 1"
        And I click "MW"
        Then I should see "View Data"
        And I should see "08:00 - 10:00"
        And I should not see "09:00 - 10:00"
        And I should see "BLDG1 101"
    
    Scenario: User should see an appropriate message if no rooms exist
        Given I am logged in as a user with first name "Test"
        And a schedule exists with the schedule name "Sched 1" and semester name "Fall 2024"
        When I visit the room bookings page for "Sched 1"
        Then I should see "View Data"
        And I should not see "Generate Remaining"
        And I should see "No rooms added to this schedule, click on View Data to Add Rooms!"

    Scenario: User should be able to go back to the schedules page
        Given I am logged in as a user with first name "Test"
        And a schedule exists with the schedule name "Sched 1" and semester name "Fall 2024"
        When I visit the room bookings page for "Sched 1"
        Then I should see "Back to Schedules"
        When I click "Back to Schedules"
        Then I should be on the schedules page

    Scenario: User should be able to create a room booking
        Given I am logged in as a user with first name "Test"
        And a schedule exists with the schedule name "Sched 1" and semester name "Fall 2024"
        And the following rooms exist for that schedule:
        | campus    | building_code | room_number | capacity | is_active | is_lab   | is_learning_studio    | is_lecture_hall   |
        | CS        | BLDG1         | 101         | 30       | true      | true     | true                  | true              |
        | GV        | BLDG2         | 102         | 50       | true      | true     | true                  | true              |
        | CS        | BLDG3         | 102         | 50       | false     | true     | true                  | true              |
        And the following time slots exist for that schedule:
        | day       | start_time    | end_time      | slot_type     |
        | MWF       | 09:00         | 10:00         | "LEC"         |
        | MW        | 08:00         | 10:00         | "LEC"         |
        And the following courses and their sections exist:
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
        And a schedule exists with the schedule name "Sched 1" and semester name "Fall 2024"
        And the following rooms exist for that schedule:
        | campus    | building_code | room_number | capacity | is_active | is_lab   | is_learning_studio    | is_lecture_hall   |
        | CS        | BLDG1         | 101         | 30       | true      | true     | true                  | true              |
        | GV        | BLDG2         | 102         | 50       | true      | true     | true                  | true              |
        | CS        | BLDG3         | 102         | 50       | false     | true     | true                  | true              |
        And the following time slots exist for that schedule:
        | day       | start_time    | end_time      | slot_type     |
        | MWF       | 09:00         | 10:00         | "LEC"         |
        | MW        | 08:00         | 10:00         | "LEC"         |
        And the following courses and their sections exist:
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
        And a schedule exists with the schedule name "Sched 1" and semester name "Fall 2024"
        And the following rooms exist for that schedule:
        | campus    | building_code | room_number | capacity | is_active | is_lab   | is_learning_studio    | is_lecture_hall   |
        | CS        | BLDG1         | 101         | 30       | true      | true     | true                  | true              |
        | GV        | BLDG2         | 102         | 50       | true      | true     | true                  | true              |
        | CS        | BLDG3         | 102         | 50       | false     | true     | true                  | true              |
        And the following time slots exist for that schedule:
        | day       | start_time    | end_time      | slot_type     |
        | MWF       | 09:00         | 10:00         | "LEC"         |
        | MW        | 08:00         | 10:00         | "LEC"         |
        And the following courses and their sections exist:
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
        And a schedule exists with the schedule name "Sched 1" and semester name "Fall 2024"
        And the following rooms exist for that schedule:
        | campus    | building_code | room_number | capacity | is_active | is_lab   | is_learning_studio    | is_lecture_hall   |
        | CS        | BLDG1         | 101         | 30       | true      | true     | true                  | true              |
        | GV        | BLDG2         | 102         | 50       | true      | true     | true                  | true              |
        | CS        | BLDG3         | 102         | 50       | false     | true     | true                  | true              |
        And the following time slots exist for that schedule:
        | day       | start_time    | end_time      | slot_type     |
        | MWF       | 09:00         | 10:00         | "LEC"         |
        | MW        | 08:00         | 10:00         | "LEC"         |
        And the following courses and their sections exist:
        | course_number       | max_seats | lecture_type | num_labs         | sections      |
        | 110                 | 96        | F2F          | 4                | 100,101       |
        | 110                 | 96        | F2F          | 4                | 100     |
        | 111                 | 96        | F2F          | 4                | 100       |
        | 435/735/735D        | 135       | F2F          | 2                | 100      |
        And the following instructors exist:
        | id_number | first_name | last_name | middle_name | email            | before_9    | after_3  | beaware_of |
        | 1001      | John       | Doe       | A           | john@example.com | true        | false    | test       |
        | 1002      | Jane       | Smith     | B           | jane@example.com | false       | false    |            |
        When I visit the room bookings page for "Sched 1"
        And I book room "BLDG1" "101" in "MWF" for "09:00 - 10:00" with "100" for "110"
        Then I should see "Unlocked"