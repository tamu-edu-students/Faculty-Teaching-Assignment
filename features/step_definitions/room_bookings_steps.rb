# frozen_string_literal: true

Given(/I am on the room bookings page for "(.*)"/) do |schedule_name|
  @schedule = @user.schedules.find_by(schedule_name:)
  visit schedule_room_bookings_path(@schedule)
end

Given('the following courses and their sections exist for schedule {string}:') do |string, table|
  schedule = Schedule.find_by(schedule_name: string)
  table.hashes.each do |row|
    # Create the course with the given name
    course = Course.create!(
      course_number: row['course_number'],
      max_seats: row['max_seats'],
      lecture_type: row['lecture_type'],
      num_labs: row['num_labs'],
      schedule:
    )

    # Create sections associated with the course
    row['sections'].split(',').each do |section_name|
      Section.create!(
        course:,
        section_number: section_name,
        seats_alloted: 24
      )
    end
  end
end

When(/^I visit the room bookings page for "(.*)"$/) do |schedule_name|
  @schedule = @user.schedules.find_by(schedule_name:)
  visit schedule_room_bookings_path(@schedule)
end

Given('the following time slots exist for schedule {string}:') do |_string, table|
  table.hashes.each do |time_slot|
    TimeSlot.create!(
      day: time_slot['day'],
      start_time: time_slot['start_time'],
      end_time: time_slot['end_time'],
      slot_type: time_slot['slot_type']
    )
  end
end

When(/^I click on the booking table in "(.*)" for "(.*)" in "(.*)" "(.*)"$/) do |day, time, bldg, room|
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
  expect(button[:href]).to include(room.id.to_s)
end

When(/^I click the select "(.*)" for "(.*)"$/) do |section_number, course_number|
  # Find the button using the section number
  course = @schedule.courses.find_by(course_number:)
  section = Section.find_by(course:, section_number:)
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
  section = Section.find_by(course:, section_number:)

  page.driver.post room_bookings_path(schedule_id: @schedule.id), {
    room_booking: {
      room_id: room.id,
      time_slot_id: time_slot.id,
      section_id: section.id
    }
  }

  visit schedule_room_bookings_path(@schedule)
end

When(/^I assign "(.*)" to "(.*)" "(.*)" in "(.*)" for "(.*)" with "(.*)" for "(.*)"$/) do |first_name, bldg, room, day, time, section_number, course_number|
  # Find the room based on schedule and building code
  room = @schedule.rooms.find_by(building_code: bldg, room_number: room)
  expect(room).not_to be_nil, 'Could not find room'

  # Find the time slot based on day and time
  start_time, end_time = time.split(' - ')
  time_slot = TimeSlot.find_by(day:, start_time:, end_time:)
  expect(time_slot).not_to be_nil, "Could not find time slot for '#{day} #{time}'"

  course = @schedule.courses.find_by(course_number:)
  section = Section.find_by(course:, section_number:)

  booking = RoomBooking.find_by(room:, time_slot:)

  instructor = @schedule.instructors.find_by(first_name:)

  page.driver.submit :patch, update_instructor_schedule_room_booking_path(@schedule, booking), {
    room_booking: {
      room_id: room.id,
      time_slot_id: time_slot.id,
      section_id: section.id,
      instructor_id: instructor.id
    }
  }

  visit schedule_room_bookings_path(@schedule)
end

Given('the following room bookings exist:') do |table|
  table.hashes.each do |attributes|
    # Find or create the schedule first if it's not already set
    schedule = @schedule || Schedule.find_by(schedule_name: 'Sched 1')

    # Ensure the room is created and associated with the schedule
    room = Room.find_or_create_by!(
      building_code: attributes['building_code'],
      room_number: attributes['room_number'],
      schedule:
    )

    # Ensure the time slot is created
    time_slot = TimeSlot.find_or_create_by!(
      day: attributes['day'],
      start_time: attributes['start_time'],
      end_time: attributes['end_time']
    )

    # Ensure the course and section are created and associated with the schedule
    course = Course.find_or_create_by!(
      course_number: attributes['course_number'],
      schedule:
    )

    section = Section.find_or_create_by!(
      course:,
      section_number: attributes['section_number']
    )

    # Ensure the instructor is created
    instructor = Instructor.find_or_create_by!(
      first_name: attributes['first_name'],
      last_name: attributes['last_name'],
      schedule:
    )

    # Create the RoomBooking with all necessary associations
    RoomBooking.create!(
      room:,
      time_slot:,
      section:,
      instructor:
    )
  end
end

Then('I should receive a CSV file with the filename {string}') do |filename|
  expect(page.response_headers['Content-Disposition']).to include("attachment; filename=\"#{filename}\"")
  expect(page.response_headers['Content-Type']).to include('text/csv')
end

Then('the CSV file should contain the following headers:') do |table|
  csv = CSV.parse(page.body, headers: true)
  expected_headers = table.raw.flatten
  expect(csv.headers).to include(*expected_headers)
end

Then('the CSV file should contain the following rows:') do |table|
  csv = CSV.parse(page.body, headers: true)
  expected_rows = table.hashes

  expected_rows.each_with_index do |expected_row, index|
    expected_row.each do |header, value|
      expect(csv[index][header]).to eq(value)
    end
  end
end
