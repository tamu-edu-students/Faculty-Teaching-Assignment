# frozen_string_literal: true
When('I visit the time slots page for {string}') do |schedule_name|
  schedule = Schedule.find_by(schedule_name:)
  visit schedule_time_slots_path(schedule)
end

When('I select {string} from the {string} dropdown') do |option, dropdown_label|
  select option, from: dropdown_label
end

Then('I should see a time slot for {string} from {string} to {string} of type {string}') do |day, start_time, end_time, slot_type|
  within('.timeTable-table') do
    expect(page).to have_content("#{day} #{start_time} #{end_time} #{slot_type}")
  end
end

Then('I should not see a time slot for {string} from {string} to {string} of type {string}') do |day, start_time, end_time, slot_type|
  within('.timeTable-table') do
    expect(page).not_to have_content("#{day} #{start_time} #{end_time} #{slot_type}")
  end
end
