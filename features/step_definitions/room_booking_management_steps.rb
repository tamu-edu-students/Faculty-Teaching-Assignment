# frozen_string_literal: true

Given('a room booking exists for {string} with room {string} {string} at {string} that is available') do |schedule, building, room, start|
  RoomBooking.create!(
    room: Room.find_by(schedule_id: Schedule.find_by(schedule_name: schedule), building_code: building, room_number: room),
    time_slot: TimeSlot.find_by(start_time: start),
    is_available: true,
    is_lab: false
  )
end

When('I toggle availability for the room booking in {string} {string} at {string}') do |building, room, start|
  timeslot = TimeSlot.find_by(start_time: start)
  row = find('tr', text: "#{timeslot.start_time} - #{timeslot.end_time}")
  room_headers = all('th')
  room_header_index = room_headers.find_index { |header| header.text == "#{building} #{room}" }
  room_cell = row.all('td')[room_header_index - 1]
  room_cell.find_button('BL').click
end

When('I toggle unavailability for the room booking in {string} {string} at {string}') do |building, room, start|
  timeslot = TimeSlot.find_by(start_time: start)
  row = find('tr', text: "#{timeslot.start_time} - #{timeslot.end_time}")
  room_headers = all('th')
  room_header_index = room_headers.find_index { |header| header.text == "#{building} #{room}" }
  room_cell = row.all('td')[room_header_index - 1]
  room_cell.find_button('U').click
end

Then('the booking in {string} {string} at {string} {string} should be unavailable') do |building, room, start, days|
  expect(RoomBooking.find_by(
    room: Room.find_by(schedule_id: @schedule.id, building_code: building, room_number: room),
    time_slot: TimeSlot.find_by(start_time: start, day: days)
  ).is_available).to eq(false)
end
Then('the booking in {string} {string} at {string} {string} should be available') do |building, room, start, days|
  expect(RoomBooking.find_by(
    room: Room.find_by(schedule_id: @schedule.id, building_code: building, room_number: room),
    time_slot: TimeSlot.find_by(start_time: start, day: days)
  ).is_available).to eq(true)
end

Then('overlapping bookings should also be unavailable') do
  pending # Write code here that turns the phrase above into concrete actions
end
