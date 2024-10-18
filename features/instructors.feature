Feature: Instructors Page
    Scenario: User should not be able to reach an invalid schedule room
        Given I am logged in as a user with first name "Test"
        And a schedule exists with the schedule name "Sched 1" and semester name "Fall 2024"
        When I visit the instructor page for id "9a9a9a9"
        Then I should see "Schedule not found."
        
    Scenario: Successfully retrieving instructors for a valid schedule
       
        Given a schedule exists with the schedule name "Sched 1" and semester name "Fall 2024"
        And I am logged in as a user with first name "Test"
        And the following instructors exist:
        | id_number | first_name | last_name | middle_name | email           |
        | 1001      | John       | Doe       | A           | john@example.com |
        | 1002      | Jane       | Smith     | B           | jane@example.com |
        When I visit the instructors page for "Sched 1"
        Then I should see "John Doe"
        And I should see "Jane Smith"

    Scenario: Upload instructors data
        Given a schedule exists with the schedule name "Sched 1" and semester name "Fall 2024"
        And I am logged in as a user with first name "Test"
        And I am on the details page for "Sched 1"
        When I attach a valid CSV file with path "spec/fixtures/instructors/instructors_valid.csv"
        And I click on "Upload Instructor Data"
        Then I should see "CSV file uploaded successfully."
    















    Scenario: Successfully upload a valid CSV file
        Given I am on my profile page
        When I attach a valid CSV file to the upload form
        And I click the "Submit" button
        Then I should see "CSV file uploaded successfully."

    Scenario: Upload an invalid CSV file
        Given I am on my profile page
        When I attach an invalid CSV file to the upload form
        And I click the "Submit" button
        Then I should see "Cannot parse CSV file"

    Scenario: Upload without selecting a file
        Given I am on my profile page
        When I do not attach any file to the upload form
        And I click the "Submit" button
        Then I should see "Please upload a CSV file."


        