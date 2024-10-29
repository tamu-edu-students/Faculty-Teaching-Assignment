Feature: Instructors Page
    As a scheduler
    I want to view the list of instructors and their preferences
    So that I can review instructor details that are being used to generate the schedule

    Scenario: User should not be able to reach an invalid schedule instructor page
        Given I am logged in as a user with first name "Test"
        And a schedule exists with the schedule name "Sched 1" and semester name "Fall 2024"
        When I visit the instructor page for id "9a9a9a9"
        Then I should see "Schedule not found."
        
    Scenario: User should be able to see all the instructors for a schedule
        Given a schedule exists with the schedule name "Sched 1" and semester name "Fall 2024"
        And I am logged in as a user with first name "Test"
        And the following instructors exist:
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

    Scenario: Upload valid instructors data
        Given a schedule exists with the schedule name "Sched 1" and semester name "Fall 2024"
        And I am logged in as a user with first name "Test"
        And I am on the details page for "Sched 1"
        When I attach a valid "instructor_file" with path "spec/fixtures/instructors/instructors_valid.csv"
        And I click the "Upload Instructor Data" button
        Then I should see "Instructors successfully uploaded."

    Scenario: User should see the preferences for an instructor
        Given a schedule exists with the schedule name "Sched 1" and semester name "Fall 2024"
        And I am logged in as a user with first name "Test"
        And the following instructors exist:
        | id_number | first_name | last_name | middle_name | email            | before_9    | after_3  | beaware_of |
        | 1001      | John       | Doe       | A           | john@example.com | true        | false    | test       |
        | 1002      | Jane       | Smith     | B           | jane@example.com | false       | false    |            |
        And the following preferences exist for "John Doe":
        | course       | preference_level |
        | 101          | 2                |
        | 411/629      | 1                |
        When I visit the instructors page for "Sched 1"
        And I click on the "View Preferences" button for "John" in the instructor table
        Then I should see "101" with the value "2"
        And I should see "411/629" with the value "1"
        
    Scenario: Upload invalid Data
        Given a schedule exists with the schedule name "Sched 1" and semester name "Fall 2024"
        And I am logged in as a user with first name "Test"
        And I am on the details page for "Sched 1"
        When I attach a valid "instructor_file" with path "spec/fixtures/instructors/instructors_missing_headers.csv"
        And I click the "Upload Instructor Data" button
        Then I should see "Missing required headers:"