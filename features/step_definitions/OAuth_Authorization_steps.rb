# frozen_string_literal: true

Given('I am on the welcome page') do
  visit welcome_path
end

Before do
  OmniAuth.config.test_mode = true
  OmniAuth.config.mock_auth[:google_oauth2] = nil
end

When('I click the button {string}') do |button_text|
  click_button(button_text)
end

When('I authorize access from Google') do
  mock_google_oauth_login
  visit '/auth/google_oauth2/callback'
end

Then('I should be on my profile page') do
  expect(current_path).to eq(user_path(User.first))
end

Then('I should be on my schedules page') do
  expect(current_path).to eq(schedules_path)
end

When('I login with a non TAMU Google account') do
  mock_google_oauth_login(non_tamu_account: true)
  visit '/auth/google_oauth2/callback'
end

Given('I am logged in as a user') do
  mock_google_oauth_login
  visit '/auth/google_oauth2/callback'
end

Then('I should be on the welcome page') do
  expect(current_path).to eq(welcome_path)
end
