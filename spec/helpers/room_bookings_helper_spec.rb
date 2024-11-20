# frozen_string_literal: true

# spec/controllers/room_bookings_controller_spec.rb
require 'rails_helper'
RSpec.describe RoomBookingsHelper, type: :helper do
    
    let!(:schedule) { create(:schedule) }
    let!(:room1) { create(:room, schedule:, building_code: 'EABB', room_number: '106', capacity: 118, is_active: true) }
    let!(:room2) { create(:room, schedule:, building_code: 'HRBB', room_number: '113', capacity: 65, is_active: true) }
    let!(:time_slot1) { create(:time_slot, day: 'Monday', start_time: '09:00', end_time: '10:00') }
    let!(:time_slot2) { create(:time_slot, day: 'Monday', start_time: '10:00', end_time: '11:00') }
    let!(:time_slot3) { create(:time_slot, day: 'MWF', start_time: '15:00', end_time: '16:00') }
    let!(:time_slot4) { create(:time_slot,day: 'MW', start_time: '8:00', end_time: '9:00') }
    let!(:time_slot5) { create(:time_slot,day: 'F', start_time: '8:00', end_time: '9:00') }

    let(:course) { create(:course, schedule:, course_number: 'CS101', section_numbers: '001') }
    let(:course2) { create(:course, schedule:, course_number: 'CS101', section_numbers: '002') }
    let(:course3) { create(:course, schedule:, course_number: 'CS101', section_numbers: '003') }
    let(:course4) { create(:course, schedule:, course_number: 'CS102', section_numbers: '001') }
    let(:course5) { create(:course, schedule:, course_number: 'CS102', section_numbers: '002') }
    let(:course6) { create(:course, schedule:, course_number: 'CS102', section_numbers: '003') }
    

    # let(:course2) { create(:course, schedule:, course_number: 'CS102') }

    # let(:section) { create(:section, course:, section_number: '001') }
    # let(:section2) { create(:section, course:, section_number: '002') }
    # let(:section3) { create(:section, course:, section_number: '003') }
    # let(:section4) { create(:section, course: course2, section_number: '001') }
    # let(:section5) { create(:section, course: course2, section_number: '002') }
    # let(:section6) { create(:section, course: course2, section_number: '003') }
    let!(:instructor) { create(:instructor, first_name: 'John', last_name: 'Doe') }
    let!(:instructor1) { create(:instructor, schedule:, first_name: 'Bobby', last_name: 'Floss', before_9: true, after_3: false, max_course_load: 1) }
    let!(:instructor2) { create(:instructor, schedule:, first_name: 'Robert', last_name: 'Across', before_9: false, after_3: true, max_course_load: 1) }
    let!(:instructor3) { create(:instructor, schedule:, first_name: 'Robby', last_name: 'Loss', before_9: true, after_3: true, max_course_load: 2) }
    let!(:preference11) { create(:instructor_preference, instructor: instructor1, course: course, preference_level: '5') }
    let!(:preference12) { create(:instructor_preference, instructor: instructor1, course: course4, preference_level: '3') }
    let!(:preference21) { create(:instructor_preference, instructor: instructor2, course: course, preference_level: '3') }
    let!(:preference22) { create(:instructor_preference, instructor: instructor2, course: course4, preference_level: '3') }
    let!(:preference31) { create(:instructor_preference, instructor: instructor3, course: course, preference_level: '4') }
    let!(:preference32) { create(:instructor_preference, instructor: instructor3, course: course4, preference_level: '3') }
    # let!(:room_booking1) { create(:room_booking, room: room1, time_slot: time_slot1, section:, instructor:, is_available: true) }
    # let!(:room_booking2) { create(:room_booking, room: room2, time_slot: time_slot2, section: section, instructor:, is_available: true) }
    
    
    let!(:room_booking31) { create(:room_booking, room: room1, time_slot: time_slot3, course: course,  is_available: true) }
    let!(:room_booking41) { create(:room_booking, room: room1, time_slot: time_slot4, course: course2,  is_available: true) }
    let!(:room_booking51) { create(:room_booking, room: room1, time_slot: time_slot5, course: course5,  is_available: true) }
    let!(:room_booking32) { create(:room_booking, room: room2, time_slot: time_slot3, course: course6,  is_available: true) }
    let!(:room_booking42) { create(:room_booking, room: room2, time_slot: time_slot4, course: course4,  is_available: true) }
    let!(:room_booking52) { create(:room_booking, room: room2, time_slot: time_slot1, course: course,  is_available: true) }
    # before do
    #     @user = User.create!(uid: '12345', provider: 'google_oauth2', email: 'test@example.com', first_name: 'John', last_name: 'Doe')
    #     allow(controller).to receive(:logged_in?).and_return(true)
    #     controller.instance_variable_set(:@current_user, @user)
    # end
    describe 'eligible_instructors' do
      it "filters out instructors who can't teach before 9" do 
        ans = eligible_instructors(schedule, room_booking41)
        expect(ans).to match_array([instructor1, instructor3])
      end

      it "filters out teachers who can't teach before 3" do 
        ans = eligible_instructors(schedule, room_booking31)
        expect(ans).to match_array([instructor3, instructor2])
      end

      it "leaves out teachers with have met max_course_load" do
        instructor1.update(max_course_load: 0)
        ans = eligible_instructors(schedule, room_booking51)
        expect(ans).to match_array([instructor3])
      end

      it "sorts teachers by prefrence, then by bandidth" do 
        ans = eligible_instructors(schedule, room_booking52)
        expect(ans).to match_array([instructor3, instructor2, instructor1])
      end
    end

end