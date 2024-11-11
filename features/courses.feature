Feature: Courses Page
    As a scheduler
    I should be able to upload couses and view them
    So that I can review the courses and sections used to generate the schedule

    Scenario: User should not be able to reach an invalid schedule's courses page
        Given I am logged in as a user with first name "Test"
        And a schedule exists with the schedule name "Sched 1" and semester name "Fall 2024"
        When I visit the courses page for id "9a9a9a9"
        Then I should see "Schedule not found."
    
    Scenario: User should be able to see course view with an appropriate message even if there is no data
        Given I am logged in as a user with first name "Test"
        And a schedule exists with the schedule name "Sched 1" and semester name "Fall 2024"
        When I visit the courses page for "Sched 1" 
        Then I should see "No courses added to this schedule!"
    
    Scenario: User should be able to see uploaded courses and details
        Given I am logged in as a user with first name "Test"
        And a schedule exists with the schedule name "Sched 1" and semester name "Fall 2024"
        And the following courses exist for that schedule:
        | course_number       | max_seats | lecture_type | num_labs |
        | 110                 | 96        | F2F          | 4              |
        | 110                 | 96        | F2F          | 4              |
        | 111                 | 96        | F2F          | 4              |
        | 111/708 (86/10)     | 96        | F2F          | 5              |
        | 120                 | 96        | F2F          | 4              |
        | 120                 | 96        | F2F          | 4              |
        | 120                 | 96        | F2F          | 4              |
        | 120                 | 96        | F2F          | 4              |
        | 120                 | 96        | F2F          | 4              |
        | 435/735/735D        | 135       | F2F          | 2              |

        When I visit the courses page for "Sched 1"
        Then I should see "Course Number"
        And I should see "Max Seats"
        And I should see "Lecture Type"
        And I should see "Number of Labs"
        And I should see "Sections"

        When I click "Course Number"
        Then I should see "435/735/735D" first

    Scenario: User should be able to upload a valid course file
        Given a schedule exists with the schedule name "Sched 1" and semester name "Fall 2024"
        And I am logged in as a user with first name "Test"
        And I am on the details page for "Sched 1"
        When I attach a valid "course_file" with path "spec/fixtures/courses/Course_list_valid.csv"
        And I click the "Upload Course Data" button
        Then I should see "Courses successfully uploaded."
    
    Scenario: User should see an appropriate message if click on upload without attaching a file
        Given a schedule exists with the schedule name "Sched 1" and semester name "Fall 2024"
        And I am logged in as a user with first name "Test"
        And I am on the details page for "Sched 1"
        When I click the "Upload Course Data" button
        Then I should see "Please upload a CSV file."
        
    Scenario: User should be able to hide course visibility from the generator
        Given I am logged in as a user with first name "Test"
        And a schedule exists with the schedule name "Sched 1" and semester name "Fall 2024"
        And the following courses exist for that schedule:
        | course_number       | max_seats | lecture_type | num_labs |
        | 110                 | 96        | F2F          | 4              |
        | 110                 | 96        | F2F          | 4              |
        | 111                 | 96        | F2F          | 4              |
        | 111/708 (86/10)     | 96        | F2F          | 5              |
        | 120                 | 96        | F2F          | 4              |
        | 120                 | 96        | F2F          | 4              |
        | 120                 | 96        | F2F          | 4              |
        | 120                 | 96        | F2F          | 4              |
        | 120                 | 96        | F2F          | 4              |
        | 435/735/735D        | 135       | F2F          | 2              |

        When I visit the courses page for "Sched 1"
        And I hide course "111/708 (86/10)" from generator
        Then I should see "Course updated successfully."
        And I should not see "111/708 (86/10)"

    Scenario: User should be able to filter courses based visibility from the generator
        Given I am logged in as a user with first name "Test"
        And a schedule exists with the schedule name "Sched 1" and semester name "Fall 2024"
        And the following courses exist for that schedule:
        | course_number       | max_seats | lecture_type | num_labs |
        | 110                 | 96        | F2F          | 4              |
        | 111                 | 96        | F2F          | 4              |
        | 111/708 (86/10)     | 96        | F2F          | 5              |
        | 120                 | 96        | F2F          | 4              |
        | 435/735/735D        | 135       | F2F          | 2              |

        When I visit the courses page for "Sched 1"
        And I hide course "111/708 (86/10)" from generator
        Then I should see "Course updated successfully."
        And I should not see "111/708 (86/10)"
        When I click "Show Hidden Courses"
        Then I should see "111/708 (86/10)"
    
    Scenario: User should not be able to hide course visibility from the generator for assigned courses
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
        And I visit the courses page for "Sched 1" 
        And I hide course "110" from generator
        Then I should see "Cannot hide course because it has associated room bookings."
        And I should not see "Keep"