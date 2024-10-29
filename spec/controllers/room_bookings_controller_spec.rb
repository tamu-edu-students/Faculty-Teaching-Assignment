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
        @user = User.create!(uid: '12345', provider: 'google_oauth2', email: 'test@example.com', first_name: 'John',
                                last_name: 'Doe')
        allow(controller).to receive(:logged_in?).and_return(true)
        controller.instance_variable_set(:@current_user, @user)
    end

    describe "GET #index" do
        context "when room_booking already exists" do
            before do
                get :index, params: { schedule_id: schedule.id }
            end
        
            it "returns a successful response" do
                expect(response).to have_http_status(:success)
            end
        
            it "assigns @rooms" do
                expect(assigns(:rooms)).to match_array([room1, room2])
            end
        
            it "assigns @time_slots" do
                expect(assigns(:time_slots)).to match_array([time_slot1, time_slot2])
            end
        
            it "assigns @bookings_matrix with room_booking data" do
                bookings_matrix = assigns(:bookings_matrix)
                expect(bookings_matrix[[room1.id, time_slot1.id]]).to eq(room_booking1)
                expect(bookings_matrix[[room2.id, time_slot2.id]]).to eq(room_booking2)
            end
        
            it "renders the index template" do
                expect(response).to render_template(:index)
            end
        end
    end
end
