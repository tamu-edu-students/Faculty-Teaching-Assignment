Feature: Rooms Page
    Scenario: User should be able to see room view
        Given I am logged in as a user with first name "Test"
        When I visit the rooms page
        Then I should see "Campus"
        And I should see "Building Code"
        And I should see "Show Active Rooms"
    
    Scenario: User should be able to filter only the active rooms
        Given I am logged in as a user with first name "Test"
        When I visit the rooms page
        And I click "Show Active Rooms"
        Then I should see "ZACH"
        But I should not see "AIEN"