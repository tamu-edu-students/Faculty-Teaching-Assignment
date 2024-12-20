Feature: Instructors Page
    As a scheduler
    I want to view the list of instructors and their preferences
    So that I can review instructor details that are being used to generate the schedule

    Background: courses in database

    Given the user "John" exists
    And the following schedules exist for the user "John":
    | schedule_name     | semester_name |
    | Sched 1   | Fall 2024     |

    Given the following courses exist:
    | course_id     |
    | 120           |    
    | 465D/765D     |
    
    Scenario: User should not be able to reach an invalid schedule instructor page
        Given I am logged in as a user with first name "John"
        When I visit the instructor page for id "9a9a9a9"
        Then I should see "Schedule not found."
        
    Scenario: User should be able to see all the instructors for a schedule
        Given I am logged in as a user with first name "John"
        And the following instructors exist for schedule "Sched 1":
        | id_number | first_name | last_name | middle_name | email            | before_9    | after_3  | beaware_of |
        | 1001      | John       | Doe       | A           | john@example.com | true        | false    | test       |
        | 1002      | Jane       | Smith     | B           | jane@example.com | false       | false    |            |
        When I visit the instructors page for "Sched 1"
        Then I should see "John A Doe"
        And I should see "Jane B Smith"
        And I should see the value "test" for "John A Doe"
        And I should not see the value "test" for "Jane B Smith"
        And I should see the value "Yes No" for "John A Doe"
        And I should see the value "No No" for "Jane B Smith"

    Scenario: User should be able to upload a valid instructor preferences file
        And I am logged in as a user with first name "John"
        And I am on the details page for "Sched 1"
        When I attach a valid "instructor_file" with path "spec/fixtures/instructors/instructors_valid.csv"
        And I click the "Upload Instructor Data" button
        Then I should see "Instructors and Preferences successfully uploaded."

    Scenario: User should see the preferences for an instructor
        Given I am logged in as a user with first name "John"
        And the following instructors exist for schedule "Sched 1":
        | id_number | first_name | last_name | middle_name | email            | before_9    | after_3  | beaware_of |
        | 1001      | John       | Doe       | A           | john@example.com | true        | false    | test       |
        | 1002      | Jane       | Smith     | B           | jane@example.com | false       | false    |            |
        And the following preferences exist for "John Doe":
        | course         | preference_level |
        | 120            | 2                |
        | 465D/765D      | 1                |
        When I visit the instructors page for "Sched 1"
        And I click on the "View Preferences" button for "John" in the instructor table
        Then I should see "120" with the value "2"
        And I should see "465D/765D" with the value "1"
        
    Scenario: User should see an error message if they upload an invalid instructor file
        And I am logged in as a user with first name "John"
        And I am on the details page for "Sched 1"
        When I attach a valid "instructor_file" with path "spec/fixtures/instructors/instructors_missing_headers.csv"
        And I click the "Upload Instructor Data" button
        Then I should see "Missing required headers:"