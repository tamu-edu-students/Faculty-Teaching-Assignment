Feature: Room Booking Management

    Background: schedules in database
    Given the user "John" exists
    And the following schedules exist for the user "John":
        | schedule_name     | semester_name |
        | Sched 1   | Fall 2024     |
        | Dummy Sched | Fall 2024   |
    And the following rooms exist for schedule "Sched 1":
        | campus    | building_code | room_number | capacity | is_active | is_lab   | is_learning_studio    | is_lecture_hall   |
        | CS        | BLDG1         | 101         | 30       | true      | true     | true                  | true              |
        | GV        | BLDG2         | 102         | 50       | true      | true     | true                  | true              |
        | CS        | BLDG3         | 102         | 50       | false     | true     | true                  | true              |
    And the following time slots exist:
        | day       | start_time    | end_time      | slot_type     |
        | MWF       | 09:00         | 10:00         | "LEC"         |
        | MW        | 09:00         | 10:00         | "LEC"         |
        | F         | 09:00         | 10:00         | "LEC"         |

    Scenario: Toggling room booking availability
        Given I am logged in as a user with first name "John" 
        When I visit the room bookings page for "Sched 1"        
        And I toggle availability for the room booking in "BLDG1" "101" at "09:00"
        Then the booking in "BLDG1" "101" at "09:00" "MWF" should be unavailable

        When I click "MW" 
        And I toggle unavailability for the room booking in "BLDG1" "101" at "09:00"

        Then the booking in "BLDG1" "101" at "09:00" "F" should be unavailable
        And the booking in "BLDG1" "101" at "09:00" "MW" should be available
        And the booking in "BLDG1" "101" at "09:00" "MWF" should be available