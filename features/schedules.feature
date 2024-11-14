Feature: Schedules page
    As a scheduler
    So that I can see the schedules I have worked on
    I want to see the list of my schedules on the landing page and be able to search them

    Background: schedules in database

    Given the user "John" exists
    And the user "Dummy" exists
    And the following schedules exist for the user "John":
    | schedule_name     | semester_name |
    | Test Schedule 1   | Fall 2024     |
    | Another Schedule  | Spring 2024   |
    And the following schedules exist for the user "Dummy":
    | schedule_name     | semester_name |
    | Dummys Schedule   | Summer 2024     |

    Scenario: User sees landing page with only his generated schedules
        Given I am logged in as a user with first name "John"
        When I visit the schedules index page
        Then I should see "Test Schedule 1"
        And I should see "Another Schedule"
        And I should not see "Dummys Schedule"
        
    Scenario: User should be able to see each schedule's details
        Given I am logged in as a user with first name "John"
        When I visit the schedules index page
        And I click on the card for "Test Schedule 1"
        Then I should see "Schedule Name: Test Schedule 1"
        And I should see "Semester: Fall 2024"
        But I should not see "Another Schedule"

    Scenario: User should be able to search for existing schedules
        Given I am logged in as a user with first name "John"
        When I visit the schedules index page
        When I search for "Test Schedule"
        Then I should see "Test Schedule 1"
        But I should not see "Another Schedule"

    Scenario: Search for a non-existing schedule
        Given I am logged in as a user with first name "John"
        When I visit the schedules index page
        When I search for "ABCD"
        Then I should not see "Test Schedule 1"
        And I should not see "Another Schedule"

    Scenario: User can upload room CSV
        Given I am logged in as a user with first name "John"
        When I visit the schedules index page
        And I click on the card for "Test Schedule 1" 
        Then I should see "Select Room Data (CSV)"
        When I upload a valid room file 
        And I click the "Upload Room Data" button
        Then I should see "Rooms successfully uploaded"

    Scenario: User can upload instructor CSV only if courses are uploaded
        Given I am logged in as a user with first name "John"
        When I visit the schedules index page
        And I click on the card for "Test Schedule 1" 
        Then I should see "Select Instructor Data (CSV)"
        And I should see the "Upload Instructor Data" button is disabled

        # Step to upload courses
        When I attach a valid "course_file" with path "spec/fixtures/courses/Course_list_valid.csv"
        And I click the "Upload Course Data" button
        Then I should see "Courses successfully uploaded"

        # Now instructor upload should be enabled
        When I attach a valid "instructor_file" with path "spec/fixtures/instructors/instructors_valid.csv"
        And I click the "Upload Instructor Data" button
        Then I should see "Instructors and Preferences successfully uploaded"
 