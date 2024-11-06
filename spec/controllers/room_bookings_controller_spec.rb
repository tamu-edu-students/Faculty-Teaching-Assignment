# frozen_string_literal: true

# spec/controllers/room_bookings_controller_spec.rb
require 'rails_helper'

RSpec.describe RoomBookingsController, type: :controller do
  render_views
  let!(:schedule) { create(:schedule) }
  let!(:room1) { create(:room, schedule:) }
  let!(:room2) { create(:room, schedule:) }
  let!(:time_slot1) { create(:time_slot, day: 'Monday', start_time: '09:00', end_time: '10:00') }
  let!(:time_slot2) { create(:time_slot, day: 'Monday', start_time: '10:00', end_time: '11:00') }
  let(:course) { create(:course, schedule:) }
  let(:section) { create(:section, course:) }
  let!(:room_booking1) { create(:room_booking, room: room1, time_slot: time_slot1, section:, is_available: true, course:course) }
  let!(:room_booking2) { create(:room_booking, room: room2, time_slot: time_slot2, section:, is_available: false, course:course) }
  let(:instructor) { create(:instructor) }

  before do
    @user = User.create!(uid: '12345', provider: 'google_oauth2', email: 'test@example.com', first_name: 'John',
                         last_name: 'Doe')
    allow(controller).to receive(:logged_in?).and_return(true)
    controller.instance_variable_set(:@current_user, @user)
  end

  describe 'GET #index' do
    context 'when room_booking already exists' do
      before do
        get :index, params: { schedule_id: schedule.id }
      end

      it 'returns a successful response' do
        expect(response).to have_http_status(:success)
      end

      it 'assigns @rooms' do
        expect(assigns(:rooms)).to match_array([room1, room2])
      end

      it 'assigns @time_slots' do
        expect(assigns(:time_slots)).to match_array([time_slot1, time_slot2])
      end

      it 'assigns @bookings_matrix with room_booking data' do
        bookings_matrix = assigns(:bookings_matrix)
        expect(bookings_matrix[[room1.id, time_slot1.id]]).to eq(room_booking1)
        expect(bookings_matrix[[room2.id, time_slot2.id]]).to eq(room_booking2)
      end

      it 'renders the index template' do
        expect(response).to render_template(:index)
      end
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      it 'creates a new room booking and redirects' do
        post :create, params: {
          schedule_id: schedule.id,
          room_booking: {
            room_id: room1.id,
            time_slot_id: time_slot1.id,
            section_id: section.id,
            instructor_id: instructor.id,
            course_id: course.id,
            is_available: true,
            is_lab: false
          }
        }

        expect(RoomBooking.count).to eq(3)
        expect(flash[:notice]).to eq('Room Booking was successfully created.')
        expect(response).to redirect_to(schedule_room_bookings_path(schedule))
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the room booking and redirects with a success message' do
      delete :destroy, params: { schedule_id: schedule.id, id: room_booking1.id }

      expect(RoomBooking.exists?(room_booking1.id)).to be_falsey
      expect(flash[:notice]).to eq('Room booking deleted successfully.')
      expect(response).to redirect_to(schedule_room_bookings_path(schedule))
    end

    it 'renders an error when room booking does not exist' do
      delete :destroy, params: { schedule_id: schedule.id, id: 999 } # Non-existent room_booking ID

      expect(flash[:alert]).to eq('Room booking not found.')
      expect(response).to redirect_to(schedule_room_bookings_path(schedule))
    end
  end

  describe 'PATCH #toggle_lock' do
    it 'toggles the lock status of the room booking' do
      room_booking1.update(is_locked: false)
      patch :toggle_lock, params: { schedule_id: schedule.id, id: room_booking1.id }

      room_booking1.reload
      expect(room_booking1.is_locked).to be_truthy
      expect(flash[:notice]).to eq('Room booking lock status updated successfully.')
    end
  end

  describe 'PATCH #update_instructor' do
    it 'updates the instructor for the room booking' do
      another_instructor = create(:instructor)
      patch :update_instructor, params: {
        schedule_id: schedule.id,
        id: room_booking1.id,
        room_booking: { instructor_id: another_instructor.id }
      }

      room_booking1.reload
      expect(room_booking1.instructor).to eq(another_instructor)
      expect(flash[:notice]).to eq('Instructor updated successfully.')
    end

    it 'renders an error message when update fails' do
      allow_any_instance_of(RoomBooking).to receive(:update).and_return(false) # Force failure
      patch :update_instructor, params: {
        schedule_id: schedule.id,
        id: room_booking1.id,
        room_booking: { instructor_id: nil }
      }

      expect(flash[:alert]).to eq('Failed to update instructor.')
    end
  end
end
