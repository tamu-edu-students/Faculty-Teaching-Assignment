# frozen_string_literal: true

Given(/I am on the room bookings page for "(.*)"/) do |schedule_name|
  @schedule = Schedule.find(schedule_name: schedule_name)
  visit schedule_room_bookings_path(@schedule)
end

When(/^I visit the room bookings page for "(.*)"$/) do |schedule_name|
  @schedule = Schedule.where(schedule_name: schedule_name)[0]
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
