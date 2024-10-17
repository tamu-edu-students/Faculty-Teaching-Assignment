Feature: Schedules page
    As a scheduler
    So that I can see the schedules I have worked on
    I want to see the list of my schedules on the landing page and be able to search them

    Background: schedules in database

    Given the following schedules exist:
    | schedule_name     | semester_name |
    | Test Schedule 1   | Fall 2024     |
    | Another Schedule  | Spring 2024   |

    Scenario: User sees landing page with generated schedules
        Given I am logged in as a user with first name "Test"
        When I visit the schedules index page
        Then I should see "Test Schedule 1"
        And I should see "Another Schedule"
        
    Scenario: User should be able to see each schedule's details
        Given I am logged in as a user with first name "Test"
        When I visit the schedules index page
        And I click on the card for "Test Schedule 1"
        Then I should see "Schedule Name: Test Schedule 1"
        And I should see "Semester:Fall 2024"
        And I should see "Some details about the schedule"
        But I should not see "Another Schedule"

    Scenario: Search for an existing schedule
        Given I am logged in as a user with first name "Test"
        When I visit the schedules index page
        When I search for "Test Schedule"
        Then I should see "Test Schedule 1"
        But I should not see "Another Schedule"

    Scenario: Search for a non-existing schedule
        Given I am logged in as a user with first name "Test"
        When I visit the schedules index page
        When I search for "ABCD"
        Then I should not see "Test Schedule 1"
        And I should not see "Another Schedule"