Feature: Courses Page
    As a scheduler
    I should be able to hide courses from the scheduler
    So that I can remove those courses from the generated schedule
    
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
    And the following time slots exist for schedule 'Sched 1':
    | day       | start_time    | end_time      | slot_type     |
    | MWF       | 09:00         | 10:00         | "LEC"         |
    | MW        | 08:00         | 10:00         | "LEC"         |
    And the following courses and their sections exist for schedule 'Sched 1':
    | course_number       | max_seats | lecture_type | num_labs         | sections      |
    | 110                 | 96        | F2F          | 4                | 100,101       |
    | 110                 | 96        | F2F          | 4                | 100           |
    | 111                 | 96        | F2F          | 4                | 100           |
    | 435/735/735D        | 135       | F2F          | 2                | 100           |
    And the following instructors exist for schedule 'Sched 1':
    | id_number | first_name | last_name | middle_name | email            | before_9    | after_3  | beaware_of |
    | 1001      | John       | Doe       | A           | john@example.com | true        | false    | test       |
    | 1002      | Jane       | Smith     | B           | jane@example.com | false       | false    |            |

    Scenario: User should not be able to hide course visibility from the generator for assigned courses
        Given I am logged in as a user with first name "John"
        When I visit the room bookings page for "Sched 1"
        And I book room "BLDG1" "101" in "MWF" for "09:00 - 10:00" with "100" for "110"
        And I visit the courses page for "Sched 1" 
        And I hide course "110" from generator
        Then I should see "Cannot hide course because it has associated room bookings."
        And I should not see "Keep"