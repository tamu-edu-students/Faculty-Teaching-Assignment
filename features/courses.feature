Feature: Courses Page
    

    Scenario: User should not be able to reach an invalid schedule course
        Given I am logged in as a user with first name "Test"
        And a schedule exists with the schedule name "Sched 1" and semester name "Fall 2024"
        When I visit the courses page for id "9a9a9a9"
        Then I should see "Schedule not found."
    
    Scenario: User should be able to see course view even if there is now data
        Given I am logged in as a user with first name "Test"
        And a schedule exists with the schedule name "Sched 1" and semester name "Fall 2024"
        When I visit the courses page for "Sched 1" 
        Then I should see "No courses added to this schedule!"
    
    Scenario: User should be able to see course view
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



    
    Scenario: Upload courses data success
        Given a schedule exists with the schedule name "Sched 1" and semester name "Fall 2024"
        And I am logged in as a user with first name "Test"
        And I am on the details page for "Sched 1"
        When I attach a valid "course_file" with path "spec/fixtures/courses/Course_list_valid.csv"
        And I click the "Upload Course Data" button
        Then I should see "Courses successfully uploaded."
    Scenario: Upload courses data empty

        Given a schedule exists with the schedule name "Sched 1" and semester name "Fall 2024"
        And I am logged in as a user with first name "Test"
        And I am on the details page for "Sched 1"
        When I click the "Upload Course Data" button
        Then I should see "Please upload a CSV file."


    
        