# frozen_string_literal: true

Given('the following instructors exist:') do |table|
  table.hashes.each do |hash|
    Instructor.create!(
      id_number: hash['id_number'],
      first_name: hash['first_name'],
      last_name: hash['last_name'],
      middle_name: hash['middle_name'],
      email: hash['email'],

      schedule: @schedule # Associate instructors with the created schedule
    )
  end
end

When(/I visit the instructors page for "(.*)"/) do |_schedule_name|
  visit schedule_instructors_path(schedule_id: @schedule.id)
end

# Step to visit an instructor page based on schedule ID
When('I visit the instructor page for id {string}') do |schedule_id|
  visit schedule_instructors_path(schedule_id) # Replace with the correct route for your app
end

Given('there is no schedule with id {string}') do |schedule_id|
  # This step can be left empty as it is assumed that the schedule does not exist
  expect(Schedule.find_by(id: schedule_id)).to be_nil
end

When('I visit the instructors index for schedule {string}') do |schedule_id|
  visit schedule_instructors_path(schedule_id) # Adjust this based on your routes
end

Given('I am on the details page for {string}') do |_schedule_name|
  visit schedule_path(id: @schedule.id) # Adjust this based on your routes
end

When('I attach a valid {string} with path {string}') do |csv_location, file_path|
  attach_file(csv_location, Rails.root.join(file_path))
end
