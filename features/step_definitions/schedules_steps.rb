# frozen_string_literal: true

Given(/the following schedules exist/) do |schedules_table|
    schedules_table.hashes.each do |schedule|
      Schedule.create schedule
    end
end
When('I visit the landing page') do
    visit schedules_path
end

When('I click on {string}') do |schedule_name|
    # Find the specific card that contains the schedule name in the h4 tag and click the stretched link
    card = find('div.sched-card', text: schedule_name, match: :first)
    card.find('a.stretched-link').click
end  

Then('I should not see {string}') do |string|
    expect(page).not_to have_content string
end

Given('I am on the new schedule page') do
    visit new_schedule_path
  end
  
  When('I fill in {string} with {string}') do |field_name, value|
    fill_in field_name, with: value
  end

