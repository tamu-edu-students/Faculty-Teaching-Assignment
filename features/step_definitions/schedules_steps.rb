# frozen_string_literal: true

Given(/the following schedules exist/) do |schedules_table|
  schedules_table.hashes.each do |schedule|
    Schedule.create schedule
  end
end
When('I visit the schedules index page') do
  visit schedules_path
end

When('I click on the card for {string}') do |schedule_name|
  # Find the specific card that contains the schedule name in the h4 tag and click the stretched link
  card = find('div.sched-card', text: schedule_name, match: :first)
  card.find('a.stretched-link').click
end

Given('I am on the new schedule page') do
  visit new_schedule_path
end

Given('I am on the schedules index page') do
  visit schedules_path
end

Given('I have created a schedule called {string}') do |schedule_name|
  Schedule.create!(schedule_name: schedule_name, semester_name: 'Fall 2024')
end

When('I click the {string} button for {string}') do |button_name, schedule_name|
  # Find the card with the schedule name and click the delete button
  within('div.card', text: schedule_name) do
    click_button button_name
  end
end

When('I search for {string}') do |search_term|
  fill_in 'search_by_name', with: search_term
  click_button 'Search'
end
