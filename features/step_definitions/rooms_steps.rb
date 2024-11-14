# frozen_string_literal: true

Given(/I am on the rooms page for "(.*)"/) do |schedule_name|
  @schedule = Schedule.find(schedule_name:)
  visit schedule_rooms_path(schedule_id: @schedule.id)
end

When(/I visit the rooms page for "(.*)"/) do |schedule_name|
  @schedule = Schedule.find_by(schedule_name:)
  visit schedule_rooms_path(schedule_id: @schedule.id)
end

Given(/^a schedule exists with the schedule name "(.*)" and semester name "(.*)" for user "(.*)"$/) do |schedule_name, semester_name, user_name|
  @user_id = User.find_by(first_name: user_name)
  @schedule = Schedule.create!(schedule_name:, semester_name:, user: @user_id)
end

Given('the following rooms exist for schedule {string}:') do |string, table|
  schedule = Schedule.find_by(schedule_name: string)
  table.hashes.each do |room|
    Room.create!(
      campus: room['campus'],
      building_code: room['building_code'],
      room_number: room['room_number'],
      capacity: room['capacity'],
      is_active: room['is_active'] == 'true',
      is_lab: room['is_lab'] == 'true',
      is_learning_studio: room['is_learning_studio'] == 'true',
      is_lecture_hall: room['is_lecture_hall'] == 'true',
      schedule_id: schedule.id
    )
  end
end

Given(/^no rooms exist for that schedule$/) do
  # No need to create rooms
end

Then(/^I should see the following rooms:$/) do |table|
  table.rows.each do |row|
    expect(page).to have_content(row.join(' '))
  end
end

When(/^I visit the rooms page for id "(.*)"$/) do |schedule_id|
  visit schedule_rooms_path(schedule_id:)
end
