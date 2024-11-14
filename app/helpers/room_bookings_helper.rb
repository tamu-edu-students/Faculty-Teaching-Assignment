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
end
