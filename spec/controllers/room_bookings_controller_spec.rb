# frozen_string_literal: true

# spec/controllers/room_bookings_controller_spec.rb
require 'rails_helper'

RSpec.describe RoomBookingsController, type: :controller do
  let!(:schedule) { create(:schedule) }
  let!(:room1) { create(:room, schedule: schedule) }
  let!(:room2) { create(:room, schedule: schedule) }
  let!(:time_slot1) { create(:time_slot, day: 'Monday', start_time: '09:00', end_time: '10:00') }
  let!(:time_slot2) { create(:time_slot, day: 'Monday', start_time: '10:00', end_time: '11:00') }
  let!(:room_booking1) { create(:room_booking, room: room1, time_slot: time_slot1, is_available: true) }
  let!(:room_booking2) { create(:room_booking, room: room2, time_slot: time_slot2, is_available: false) }

  before do
    @user = User.create!(uid: '12345', provider: 'google_oauth2', email: 'test@example.com', first_name: 'John', last_name: 'Doe')
    allow(controller).to receive(:logged_in?).and_return(true)
    controller.instance_variable_set(:@current_user, @user)
  end

  describe 'GET #index' do
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

  describe 'POST #toggle_availability' do
    context 'when booking is currently available' do
      it 'toggles availability to false' do
        expect {
          post :toggle_availability, params: { room_id: room1.id, time_slot_id: time_slot1.id, schedule_id: schedule.id }
          room_booking1.reload
        }.to change { room_booking1.is_available }.from(true).to(false)

        # Check redirect
        expect(response).to redirect_to(schedule_room_bookings_path(schedule, active_tab: nil))
      end

      it 'toggles availability for overlapping bookings' do
        # Create another overlapping time slot
        overlapping_slot = create(:time_slot, day: 'Monday', start_time: '09:30', end_time: '10:30')
        create(:room_booking, room: room1, time_slot: overlapping_slot, is_available: true)

        expect {
          post :toggle_availability, params: { room_id: room1.id, time_slot_id: time_slot1.id, schedule_id: schedule.id }
        }.to change { RoomBooking.find_by(room: room1, time_slot: overlapping_slot).is_available }.from(true).to(false)

        # Check if the overlapping booking is updated correctly
        overlapping_booking = RoomBooking.find_by(room: room1, time_slot: overlapping_slot)
        expect(overlapping_booking.is_available).to eq(false)

        # Check redirect
        expect(response).to redirect_to(schedule_room_bookings_path(schedule, active_tab: nil))
      end
    end

    context 'when booking is currently blocked' do
      before { room_booking1.update(is_available: false) }

      it 'toggles availability to true' do
        expect {
          post :toggle_availability, params: { room_id: room1.id, time_slot_id: time_slot1.id, schedule_id: schedule.id }
          room_booking1.reload
        }.to change { room_booking1.is_available }.from(false).to(true)

        # Check redirect
        expect(response).to redirect_to(schedule_room_bookings_path(schedule, active_tab: nil))
      end

      it 'toggles availability for overlapping bookings' do
        # Create another overlapping time slot
        overlapping_slot = create(:time_slot, day: 'Monday', start_time: '09:30', end_time: '10:30')
        create(:room_booking, room: room1, time_slot: overlapping_slot, is_available: false)

        expect {
          post :toggle_availability, params: { room_id: room1.id, time_slot_id: time_slot1.id, schedule_id: schedule.id }
        }.to change { RoomBooking.find_by(room: room1, time_slot: overlapping_slot).is_available }.from(false).to(true)

        # Check if the overlapping booking is updated correctly
        overlapping_booking = RoomBooking.find_by(room: room1, time_slot: overlapping_slot)
        expect(overlapping_booking.is_available).to eq(true)

        # Check redirect
        expect(response).to redirect_to(schedule_room_bookings_path(schedule, active_tab: nil))
      end
    end
  end

  describe 'private methods' do
    describe '#calculate_relevant_days' do
      it 'returns the correct relevant days' do
        expect(controller.send(:calculate_relevant_days, 'MWF')).to match_array(%w[MWF MW F])
        expect(controller.send(:calculate_relevant_days, 'MW')).to match_array(%w[MWF MW])
        expect(controller.send(:calculate_relevant_days, 'F')).to match_array(%w[MWF F])
        expect(controller.send(:calculate_relevant_days, 'TR')).to match_array(['TR'])
      end
    end
  end
end
