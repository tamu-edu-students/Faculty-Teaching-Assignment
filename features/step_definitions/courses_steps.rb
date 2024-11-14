# frozen_string_literal: true

Given(/I am on the courses page for "(.*)"/) do |_schedule_name|
  visit schedule_courses_path(schedule_id: @schedule.id)
end

When(/I visit the courses page for "(.*)"/) do |schedule_name|
  @schedule = Schedule.find_by(schedule_name:)
  visit schedule_courses_path(schedule_id: @schedule.id)
end

Then(/I should see "(.*)" first/) do |course_num|
  first_row = find('#courses tbody tr', match: :first)
  actual_course_number = first_row.find('td:nth-child(1)').text.strip
  expect(actual_course_number).to eq(course_num)
end

Given('the following courses exist for schedule {string}:') do |string, table|
  schedule = Schedule.find_by(schedule_name: string)
  table.hashes.each do |course|
    Course.create!(
      course_number: course['course_number'],
      max_seats: course['max_seats'],
      lecture_type: course['lecture_type'],
      num_labs: course['num_labs'],

      schedule:
    )
  end
end

Then(/^I should see the following courses:$/) do |table|
  table.rows.each do |row|
    expect(page).to have_content(row.join(' '))
  end
end

When(/^I visit the courses page for id "(.*)"$/) do |schedule_id|
  visit schedule_courses_path(schedule_id:)
end

When('I hide course {string} from generator') do |course_number|
  course = @schedule.courses.find_by(course_number:)

  row = find('tr', id: "course-#{course.id}")
  room_headers = all('th')
  room_header_index = room_headers.find_index { |header| header.text == 'Generator Visibility' }
  row.all('td')[room_header_index - 1]
  row.find_link('Hide').click
end
