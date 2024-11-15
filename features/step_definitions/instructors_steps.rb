# frozen_string_literal: true

Given('the following courses exist:') do |courses_table|
  courses_table.hashes.each do |course|
    @schedule = Schedule.find_by(schedule_name: 'Sched 1')
    @schedule.courses.create!(course_number: course['course_id'])
  end
end

Given('the following instructors exist for schedule {string}:') do |string, table|
  schedule = Schedule.find_by(schedule_name: string)
  table.hashes.each do |hash|
    Instructor.create!(
      id_number: hash['id_number'],
      first_name: hash['first_name'],
      last_name: hash['last_name'],
      middle_name: hash['middle_name'],
      email: hash['email'],
      before_9: hash['before_9'] == 'true',
      after_3: hash['after_3'] == 'true',
      beaware_of: hash['beaware_of'],

      schedule: # Associate instructors with the created schedule
    )
  end
end

Given('the following preferences exist for {string}:') do |instructor_name, table|
  instructor = Instructor.find_by(first_name: instructor_name.split.first, last_name: instructor_name.split.last)
  table.hashes.each do |preference_data|
    course = @schedule.courses.find_by!(course_number: preference_data['course'].to_s)
    preference_data['course'] = course
    instructor.instructor_preferences.create!(preference_data)
  end
end

When(/I visit the instructors page for "(.*)"/) do |_schedule_name|
  visit schedule_instructors_path(schedule_id: @schedule.id)
end

# Step to visit an instructor page based on schedule ID
When('I visit the instructor page for id {string}') do |schedule_id|
  visit schedule_instructors_path(schedule_id)
end

Given('there is no schedule with id {string}') do |schedule_id|
  expect(Schedule.find_by(id: schedule_id)).to be_nil
end

When('I visit the instructors index for schedule {string}') do |schedule_id|
  visit schedule_instructors_path(schedule_id)
end

Given('I am on the details page for {string}') do |_schedule_name|
  @schedule = Schedule.find_by(schedule_name: _schedule_name)
  visit schedule_path(id: @schedule.id)
end

When('I attach a valid {string} with path {string}') do |csv_location, file_path|
  attach_file(csv_location, Rails.root.join(file_path))
end

Then('I should see the value {string} for {string}') do |string, string3|
  course_row = find('tr', text: string3)
  expect(course_row).to have_content(string.to_s)
end

Then('I should not see the value {string} for {string}') do |string, string3|
  course_row = find('tr', text: string3)
  expect(course_row).not_to have_content(string.to_s)
end

When('I click on the {string} button for {string} in the instructor table') do |button_text, instructor|
  instructor_row = find('tr', text: instructor)
  within(instructor_row) do
    click_button button_text
  end
end

Then('I should see {string} with the value {string}') do |field, value|
  course_row = first('tr', text: field)
  expect(course_row).to have_content("#{field} #{value}")
end
