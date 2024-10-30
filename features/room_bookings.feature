Feature: Rooms Page 
    Scenario: Checking a room booking
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
    
    Scenario: Checking a room booking and changing tab
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
    
    Scenario: Checking empty room bookings
        Given I am logged in as a user with first name "Test"
        And a schedule exists with the schedule name "Sched 1" and semester name "Fall 2024"
        When I visit the room bookings page for "Sched 1"
        Then I should see "View Data"
        And I should not see "Generate Remaining"
        And I should see "No rooms added to this schedule, click on View Data to Add Rooms!"