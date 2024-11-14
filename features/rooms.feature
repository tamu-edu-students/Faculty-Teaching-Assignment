Feature: Rooms Page
    As a scheduler
    I should be able to view and filter the rooms I have uploaded
    So that I can review room details that are used to generate the schedule

    Background: schedules in database
    Given the user "John" exists
    And the following schedules exist for the user "John":
    | schedule_name     | semester_name |
    | Sched 1   | Fall 2024     |
    | Dummy Sched | Fall 2024   |
    And the following rooms exist for schedule 'Sched 1':
    | campus    | building_code | room_number | capacity | is_active | is_lab   | is_learning_studio    | is_lecture_hall   |
    | CS        | BLDG1         | 101         | 30       | true      | true     | true                  | true              |
    | GV        | BLDG2         | 102         | 50       | true      | true     | true                  | true              |
    | CS        | BLDG3         | 102         | 50       | false     | true     | true                  | true              |
    
    Scenario: User should not be able to reach an invalid schedule room
        Given I am logged in as a user with first name "John"
        When I visit the rooms page for id "9a9a9a9"
        Then I should see "Schedule not found."
    
    Scenario: User should be able to see room view
        Given I am logged in as a user with first name "John"        
        When I visit the rooms page for "Sched 1"
        Then I should see "Campus"
        And I should see "Building Code"
        And I should see "Show Active Rooms"
    
    Scenario: User should be able to filter only the active rooms
        Given I am logged in as a user with first name "John"
        When I visit the rooms page for "Sched 1"
        And I click "Show Active Rooms"
        Then I should see the following rooms:
        | Building Code | Room Number | Capacity |
        | BLDG1         | 101         | 30       |
        | BLDG2         | 102         | 50       | 
        And I should not see "BLDG3"

    Scenario: User should be able to upload a valid rooms file
        And I am logged in as a user with first name "John"
        And I am on the details page for "Sched 1"
        When I attach a valid "room_file" with path "spec/fixtures/rooms/rooms_valid.csv"
        And I click the "Upload Room Data" button
        Then I should see "Rooms successfully uploaded."

    Scenario: User can go back to the schedules page by clicking on Back to schedules
        Given I am logged in as a user with first name "John"
        When I visit the rooms page for "Sched 1"
        And I click "Back to Schedules"
        Then I should be on the schedules page