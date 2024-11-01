# frozen_string_literal: true

When('I click the {string} button') do |button_text|
  click_button(button_text)
end

Then('I should see {string}') do |message|
  expect(page).to have_content(message)
end

When('I click {string}') do |text|
  click_link(text)
end

Then('I should not see {string}') do |string|
  expect(page).not_to have_content string
end

When('I fill in {string} with {string}') do |field_name, value|
  fill_in field_name, with: value
end

Then('I should be on the schedules page') do
  expect(page).to have_current_path(schedules_path)
end
