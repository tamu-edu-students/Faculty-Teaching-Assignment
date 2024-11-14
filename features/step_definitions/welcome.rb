# frozen_string_literal: true

Given('I am logged in as a user with first name {string}') do |first_name|
  mock_google_oauth_login(first_name)
  visit '/auth/google_oauth2/callback'
  @user = User.find_by(first_name: first_name)
end

When(/^I visit the welcome page$/) do
  visit welcome_path
end
