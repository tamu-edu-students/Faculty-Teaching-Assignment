# frozen_string_literal: true

Given(/I am on the room bookings page for "(.*)"/) do |schedule_name|
  @schedule = Schedule.find(schedule_name:)
  visit schedule_room_bookings_path(@schedule)
end

Given(/^the following courses and their sections exist:$/) do |table|
  table.hashes.each do |row|
    # Create the course with the given name
    course = Course.create!(
      course_number: row['course_number'],
      max_seats: row['max_seats'],
      lecture_type: row['lecture_type'],
      num_labs: row['num_labs'],

      schedule: @schedule
    )

    # Create sections associated with the course
    row['sections'].split(',').each do |section_name|
      section_data = {
        course_id: course.id,
        section_number: section_name,
        seats_alloted: 24
      }
      Section.create!(section_data)
    end
  end
end

When(/^I visit the room bookings page for "(.*)"$/) do |schedule_name|
  @schedule = Schedule.where(schedule_name:)[0]
  visit schedule_room_bookings_path(schedule_id: @schedule.id)
end

Given('the following time slots exist for that schedule:') do |table|
  table.hashes.each do |time_slot|
    TimeSlot.create!(
      day: time_slot['day'],
      start_time: time_slot['start_time'],
      end_time: time_slot['end_time'],
      slot_type: time_slot['slot_type']
    )
  end
end

When(/^I click on a the booking table in "(.*)" for "(.*)" in "(.*)" "(.*)"$/) do |day, time, bldg, room|
  # Find the room based on schedule and building code
  room = @schedule.rooms.find_by(building_code: bldg, room_number: room)
  expect(room).not_to be_nil, 'Could not find room'

  # Find the time slot based on day and time
  start_time, end_time = time.split(' - ')
  time_slot = TimeSlot.find_by(day:, start_time:, end_time:)
  expect(time_slot).not_to be_nil, "Could not find time slot for '#{day} #{time}'"

  # Locate and click on the cell
  cell = find("td.table-cell[data-room-id='#{room.id}'][data-time-slot-id='#{time_slot.id}']")
  cell.click

  button = find('a.btn.btn-primary.course-select-btn', match: :first)
  expect(button.href).contain(room.id)
end

When(/^I click the select "(.*)" for "(.*)"$/) do |section_number, course_number|
  # Find the button using the section number
  course = @schedule.courses.find_by(course_number:)
  section = Section.find_by(course_id: course.id, section_number:)
  button = find("a.btn.btn-primary.course-select-btn[data-section='#{section.id}']", match: :first)
  button.click
end

When(/^I book room "(.*)" "(.*)" in "(.*)" for "(.*)" with "(.*)" for "(.*)"$/) do |bldg, room, day, time, section_number, course_number|
  # Find the room based on schedule and building code
  room = @schedule.rooms.find_by(building_code: bldg, room_number: room)
  expect(room).not_to be_nil, 'Could not find room'

  # Find the time slot based on day and time
  start_time, end_time = time.split(' - ')
  time_slot = TimeSlot.find_by(day:, start_time:, end_time:)
  expect(time_slot).not_to be_nil, "Could not find time slot for '#{day} #{time}'"

  course = @schedule.courses.find_by(course_number:)
  section = Section.find_by(course_id: course.id, section_number:)

  page.driver.post room_bookings_path(schedule_id: @schedule.id), {
    room_booking: {
      room_id: room.id,
      time_slot_id: time_slot.id,
      section_id: section.id
    }
  }

  visit schedule_room_bookings_path(schedule_id: @schedule.id)
end
