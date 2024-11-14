Feature: Courses Page
    As a scheduler
    I should be able to upload couses and view them
    So that I can review the courses and sections used to generate the schedule

    Background: schedules in database
    Given the user "John" exists
    And the following schedules exist for the user "John":
    | schedule_name     | semester_name |
    | Sched 1   | Fall 2024     |
    | Dummy Sched | Fall 2024   |
    And the following courses exist for schedule 'Sched 1':
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
    And the following rooms exist for schedule 'Sched 1':
    | campus    | building_code | room_number | capacity | is_active | is_lab   | is_learning_studio    | is_lecture_hall   |
    | CS        | BLDG1         | 101         | 30       | true      | true     | true                  | true              |
    | GV        | BLDG2         | 102         | 50       | true      | true     | true                  | true              |
    | CS        | BLDG3         | 102         | 50       | false     | true     | true                  | true              |
    

    Scenario: User should not be able to reach an invalid schedule's courses page
        Given I am logged in as a user with first name "John"
        When I visit the courses page for id "9a9a9a9"
        Then I should see "Schedule not found."
    
    Scenario: User should be able to see course view with an appropriate message even if there is no data
        Given I am logged in as a user with first name "John"
        When I visit the courses page for "Dummy Sched" 
        Then I should see "No courses added to this schedule!"
    
    Scenario: User should be able to see uploaded courses and details
        Given I am logged in as a user with first name "John"
        When I visit the courses page for "Sched 1"
        Then I should see "Course Number"
        And I should see "Max Seats"
        And I should see "Lecture Type"
        And I should see "Number of Labs"
        And I should see "Sections"
        When I click "Course Number"
        Then I should see "435/735/735D" first

    Scenario: User should be able to upload a valid course file
        Given I am logged in as a user with first name "John"
        And I am on the details page for "Sched 1"
        When I attach a valid "course_file" with path "spec/fixtures/courses/Course_list_valid.csv"
        And I click the "Upload Course Data" button
        Then I should see "Courses successfully uploaded."
    
    Scenario: User should see an appropriate message if click on upload without attaching a file
        Given I am logged in as a user with first name "John"
        And I am on the details page for "Sched 1"
        When I click the "Upload Course Data" button
        Then I should see "Please upload a CSV file."
        
    Scenario: User should be able to hide course visibility from the generator
        Given I am logged in as a user with first name "John"
        When I visit the courses page for "Sched 1"
        And I hide course "111/708 (86/10)" from generator
        Then I should see "Course updated successfully."
        And I should not see "111/708 (86/10)"

    Scenario: User should be able to filter courses based visibility from the generator
        Given I am logged in as a user with first name "John"
        When I visit the courses page for "Sched 1"
        And I hide course "111/708 (86/10)" from generator
        Then I should see "Course updated successfully."
        And I should not see "111/708 (86/10)"
        When I click "Show Hidden Courses"
        Then I should see "111/708 (86/10)"