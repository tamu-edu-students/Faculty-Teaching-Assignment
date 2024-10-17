# frozen_string_literal: true

Given(/the following schedules exist/) do |schedules_table|
  schedules_table.hashes.each do |schedule|
    Schedule.create schedule
  end
end
When('I visit the landing page') do
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
