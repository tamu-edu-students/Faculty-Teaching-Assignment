# frozen_string_literal: true

# features/step_definitions/csv_upload_steps.rb

Given('I am on my profile page') do
  visit user_path(User.first)
end

When('I attach a valid CSV file to the upload form') do
  attach_file('csv_file', Rails.root.join('spec/fixtures/files/test.csv'))
end

When('I attach an invalid CSV file to the upload form') do
  attach_file('csv_file', Rails.root.join('spec/fixtures/files/invalid.csv'))
end

When('I do not attach any file to the upload form') do
  # No file attached
end
