# frozen_string_literal: true

# Room Bookings Helper
module RoomBookingsHelper
  def available_courses(schedule)
    @courses = Course.joins(:schedule)
                     .where(schedule_id: schedule.id, hide: false)
                     .left_joins(:room_bookings)
                     .where(room_bookings: { id: nil })
    render partial: '/shared/courses_list', locals: { courses: @courses }
  end

  def eligible_instructors(schedule, booking)
    time_slot = TimeSlot.find_by(id: booking.time_slot_id)
    current_instructor_id = booking.instructor_id
    course_id = booking.course.id
    before_9 = Time.parse('09:00 AM')
    after_3 = Time.parse('03:00 PM')
    return [] if schedule.instructors.nil?

    ans = schedule.instructors&.select do |instructor| # which instructors have time
      unless instructor.before_9
        start_time = begin
          Time.parse(time_slot.start_time)
        rescue StandardError
          nil
        end
        next if start_time < before_9 # instructor unavalible check the next
      end

      unless instructor.after_3
        end_time = begin
          Time.parse(time_slot.end_time)
        rescue StandardError
          nil
        end
        next if end_time > after_3 # instructor unavalible check the next
      end
      max = instructor.max_course_load || 1
      next if get_teach_count(instructor) >= max
      next if current_instructor_id == instructor.id
      next if is_instructor_unavailable?(instructor, booking)

      true # teacher is avalable
    end
    ans.sort_by do |instructor|
      # You can customize this sorting logic based on the structure of your `InstructorPreference` model.
      # For example, if `instructor.instructor_preferences` has a `preference_level` attribute,
      # you could sort by this value:
      preference_level = get_preference(instructor, course_id) || 0
      max = instructor.max_course_load || 1
      bandwidth = max - get_teach_count(instructor) # how many more courses a instructor can pick up
      # Return preference_level for sorting, instructors with lower preference level will come first
      [-preference_level, -bandwidth]
    end
  end

  def is_instructor_unavailable?(instructor, booking)
    time_slot = TimeSlot.find_by(id: booking.time_slot_id)
    start_time = Time.strptime(time_slot.start_time, '%H:%M')
    end_time = Time.strptime(time_slot.end_time, '%H:%M')

    # relevant_days = calculate_relevant_days(time_slot.day)

    relevant_days = case time_slot.day
                    when 'MWF' then %w[MWF MW F]
                    when 'MW' then %w[MWF MW]
                    when 'F' then %w[MWF F]
                    else [time_slot.day]
                    end

    conflicting_time_slots = TimeSlot.where(day: relevant_days).select do |slot|
      slot_start_time = begin
        Time.strptime(slot.start_time, '%H:%M')
      rescue StandardError
        nil
      end
      slot_end_time = begin
        Time.strptime(slot.end_time, '%H:%M')
      rescue StandardError
        nil
      end
      next unless slot_start_time && slot_end_time

      slot_start_time < end_time && slot_end_time > start_time
    end

    conflicting_time_slots.any? do |slot|
      RoomBooking.exists?(time_slot_id: slot.id, instructor_id: instructor.id)
    end
  end

  def get_teach_count(instructor)
    RoomBooking.where(instructor_id: instructor.id).count
  end

  def get_preference(instructor, course_id)
    return 0 unless course_id

    course_number = Course.find_by(id: course_id).course_number
    return 0 unless course_number

    courses = Course.where(course_number:)
    courses.each do |course|
      preference = instructor.instructor_preferences.find_by(course_id: course.id)

      return preference.preference_level unless preference.nil?
    end
    3
  end
end
