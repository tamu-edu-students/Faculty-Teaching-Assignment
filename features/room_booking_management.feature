Feature: Room Booking Management
    Scenario: Toggling room booking availability
        Given I am logged in as a user with first name "Test" 
        And a schedule exists with the schedule name "Sched 1" and semester name "Fall 2024"
        And the following rooms exist for that schedule:
        | campus    | building_code | room_number | capacity | is_active | is_lab   | is_learning_studio    | is_lecture_hall   |
        | CS        | BLDG1         | 101         | 30       | true      | true     | true                  | true              |
        | GV        | BLDG2         | 102         | 50       | true      | true     | true                  | true              |
        | CS        | BLDG3         | 102         | 50       | false     | true     | true                  | true              |
        And the following time slots exist:
        | day       | start_time    | end_time      | slot_type     |
        | MWF       | 09:00         | 10:00         | "LEC"         |
        | MW        | 09:00         | 10:00         | "LEC"         |
        | F         | 09:00         | 10:00         | "LEC"         |
        
        When I visit the room bookings page for "Sched 1"
        
        And I toggle availability for the room booking in "BLDG1" "101" at "09:00"
        Then the booking in "BLDG1" "101" at "09:00" "MWF" should be unavailable

        When I click "MW" 
        And I toggle unavailability for the room booking in "BLDG1" "101" at "09:00"

        Then the booking in "BLDG1" "101" at "09:00" "F" should be unavailable
        And the booking in "BLDG1" "101" at "09:00" "MW" should be available
        And the booking in "BLDG1" "101" at "09:00" "MWF" should be available