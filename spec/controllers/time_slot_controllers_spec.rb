# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TimeSlotsController, type: :controller do
  before do
    # Create a user and set session user_id as done in your application_controller_spec.rb
    @user = User.create!(uid: '12345', provider: 'google_oauth2', email: 'test@example.com', first_name: 'John',
                         last_name: 'Doe')
    session[:user_id] = @user.id
  end

  let!(:lec_slot) { TimeSlot.create!(day: 'MWF', start_time: '08:00', end_time: '08:50', slot_type: 'LEC') }
  let!(:lab_slot) { TimeSlot.create!(day: 'TR', start_time: '09:35', end_time: '10:50', slot_type: 'LAB') }

  describe 'GET index' do
    it 'renders the index template' do
      get :index
      expect(response).to render_template(:index)
    end

    it 'assigns all time slots when no filters are applied' do
      get :index
      expect(assigns(:time_slots)).to match_array([lec_slot, lab_slot])
    end

    it 'filters time slots by day' do
      get :index, params: { day: 'MWF' }
      expect(assigns(:time_slots)).to eq([lec_slot])
    end

    it 'filters time slots by type' do
      get :index, params: { slot_type: 'LAB' }
      expect(assigns(:time_slots)).to eq([lab_slot])
    end

    it 'filters time slots by day and type' do
      get :index, params: { day: 'TR', slot_type: 'LAB' }
      expect(assigns(:time_slots)).to eq([lab_slot])
    end
  end
end
