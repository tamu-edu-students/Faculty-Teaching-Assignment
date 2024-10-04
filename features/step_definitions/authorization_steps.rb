Scenario: User logs in with Google OAuth successfully
Given I am on the welcome page
When I click "Login with Google"
And I authorize access from Google
Then I should be on my profile page
And I should see "You are logged in"

Scenario: User fails to log in with a tamu account using Google OAuth
Given I am on the welcome page
When I click "Login with Google"
And I login with a non TAMYU Google account
Then I should see Access blocked: AggieAssign can only be used within its organization"

Scenario: User logs out successfully
Given I am logged in as a user
When I click "Logout"
Then I should be on the welcome page
And I should see "You are logged out"