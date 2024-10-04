Feature: support login and logout for user
  As a scheduler
  I want to login to AggieAssign with my Google account
  So that I can continue building my schedule

Scenario: User can login via OAuth
  Given I am on the home page
  When I click on "Login with Google"
  Then I should see "Howdy John!"
  And I should see "You are logged in"

