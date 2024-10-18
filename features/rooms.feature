Feature: Rooms Page
    Scenario: User should not be able to reach an invalid schedule room
        Given I am logged in as a user with first name "Test"
        And a schedule exists with the schedule name "Sched 1" and semester name "Fall 2024"
        When I visit the rooms page for id "9a9a9a9"
        Then I should see "Schedule not found."
    
    Scenario: User should be able to see room view
        Given I am logged in as a user with first name "Test"
        And a schedule exists with the schedule name "Sched 1" and semester name "Fall 2024"
        And the following rooms exist for that schedule:
        | campus    | building_code | room_number | capacity | is_active | is_lab   | is_learning_studio    | is_lecture_hall   |
        | CS        | BLDG1         | 101         | 30       | true      | true     | true                  | true              |
        | GV        | BLDG2         | 102         | 50       | true      | true     | true                  | true              |
        | CS        | BLDG3         | 102         | 50       | false     | true     | true                  | true              |
        When I visit the rooms page for "Sched 1"
        Then I should see "Campus"
        And I should see "Building Code"
        And I should see "Show Active Rooms"
    
    Scenario: User should be able to filter only the active rooms
        Given I am logged in as a user with first name "Test"
        And a schedule exists with the schedule name "Sched 1" and semester name "Fall 2024"
        And the following rooms exist for that schedule:
        | campus    | building_code | room_number | capacity | is_active | is_lab   | is_learning_studio    | is_lecture_hall   |
        | CS        | BLDG1         | 101         | 30       | true      | true     | true                  | true              |
        | GV        | BLDG2         | 102         | 50       | true      | false    | false                 | true              |
        | CS        | BLDG3         | 102         | 50       | false     | false    | true                  | true              |
        When I visit the rooms page for "Sched 1"
        And I click "Show Active Rooms"
        Then I should see the following rooms:
        | Building Code | Room Number | Capacity |
        | BLDG1         | 101         | 30       |
        | BLDG2         | 102         | 50       | 
        And I should not see "BLDG3"