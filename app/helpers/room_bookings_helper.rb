# frozen_string_literal: true

# Room Bookings Helper
module RoomBookingsHelper
    def available_sections schedule
        @sections = Section.joins(:course)
         .where(courses: { schedule_id: schedule.id })
         .left_joins(:room_booking)
         .where(room_booking: { id: nil })
        render partial: '/shared/courses_list', locals: { sections: @sections }
    end
end
