Given("I am on the welcome page") do
  visit welcome_path
end

Before do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = nil # Clear previous auth
  end

  When("I click the button {string}") do |button_text|
    click_button(button_text)
  end

When("I authorize access from Google") do
  # Mock the OAuth authorization process here
  mock_google_oauth_login
  visit '/auth/google_oauth2/callback' # Simulate the redirect from Google
end

Then("I should be on my profile page") do
  expect(current_path).to eq(user_path(User.first)) # Adjust this to your logic for user path
end

Then("I should see {string}") do |message|
  expect(page).to have_content(message)
end

When("I login with a non TAMU Google account") do
  mock_google_oauth_login(non_tamu_account: true)
  visit '/auth/google_oauth2/callback' # Simulate the redirect
end

Given("I am logged in as a user") do
  mock_google_oauth_login
  visit '/auth/google_oauth2/callback' # Simulate the redirect
end

When("I click {string}") do |text|
    click_link(text) # This will now handle clicking on links correctly
  end
  

  Then("I should be on the welcome page") do
    expect(current_path).to eq(welcome_path)
  end


