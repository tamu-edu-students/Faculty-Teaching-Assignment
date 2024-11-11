# frozen_string_literal: true

# Room Bookings Helper
module RoomBookingsHelper
  def available_sections(schedule)
    @sections = Section.joins(:course)
                       .where(courses: { schedule_id: schedule.id })
                       .left_joins(:room_booking)
                       .where(room_booking: { id: nil })
    render partial: '/shared/courses_list', locals: { sections: @sections }
  end
  def eligible_instructors(schedule, booking)
    time_slot = TimeSlot.find_by(id: booking.time_slot_id)
    current_instructor_id = booking.instructor_id 
    course_id = booking.section.course.id
    before_9 = Time.parse("09:00 AM")
    after_3 = Time.parse("03:00 PM")
    
    ans = schedule.instructors&.select do |instructor| #which instructors have time
      unless instructor.before_9
        start_time = Time.parse(time_slot.start_time)
        next if start_time < before_9 #instructor unavalible check the next
      end

      unless instructor.after_3
        end_time = Time.parse(time_slot.end_time)
        next if end_time > after_3 #instructor unavalible check the next
      end
      next if get_teach_count(instructor) == instructor.max_course_load
      next if current_instructor_id == instructor.id
      true #teacher is avalable
    end
    ans.sort_by do |instructor|
      # You can customize this sorting logic based on the structure of your `InstructorPreference` model.
      # For example, if `instructor.instructor_preferences` has a `preference_level` attribute,
      # you could sort by this value:
      preference = instructor.instructor_preferences.find_by(course_id: course_id)
      unless preference.nil?
        preference_level = preference.preference_level || 0
      else
        preference_level = 0
      end
      bandwidth = instructor.max_course_load - get_teach_count(instructor) #how many more courses a instructor can pick up
      # Return preference_level for sorting, instructors with lower preference level will come first
      [preference_level, bandwidth]
    end.reverse
    
  end

  def get_teach_count(instructor)
    bookings_for_instructor = RoomBooking.all.select do |booking|
      booking.instructor_id == instructor.id
    end
    bookings_for_instructor.length
  end
end
# no overlaping  time slots
# show first and last
# show score color code

#error multiple bookings can be plot at the same time
#shouldn't it be annomys