# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RoomsController, type: :controller do
  render_views
  let!(:room1) do
    create(:room, campus: 'CS', building_code: 'B101', room_number: '101', capacity: 50, is_active: true, is_lecture_hall: true, is_lab: false,
                  is_learning_studio: false)
  end
  let!(:room2) do
    create(:room, campus: 'GV', building_code: 'B102', room_number: '102', capacity: 30, is_active: false, is_lecture_hall: true, is_lab: false,
                  is_learning_studio: false)
  end
  let!(:room3) do
    create(:room, campus: 'NONE', building_code: 'B103', room_number: '103', capacity: 60, is_active: true, is_lecture_hall: true, is_lab: false,
                  is_learning_studio: false)
  end

  describe 'GET #index' do
    before do
      @user = User.create!(uid: '12345', provider: 'google_oauth2', email: 'test@example.com', first_name: 'John',
                           last_name: 'Doe')
      allow(controller).to receive(:logged_in?).and_return(true)
      controller.instance_variable_set(:@current_user, @user)
    end
    context 'without any filters or sorting' do
      it 'assigns all rooms to @rooms' do
        get :index
        expect(assigns(:rooms)).to match_array([room1, room2, room3])
      end
    end

    context 'with active filter' do
      it 'assigns only active rooms to @rooms' do
        get :index, params: { active_rooms: true }
        expect(assigns(:rooms)).to match_array([room1, room3])
      end
    end

    context 'with sorting by building_code in ascending order' do
      it 'assigns rooms sorted by building_code to @rooms' do
        get :index, params: { sort: 'building_code', direction: 'asc' }
        expect(assigns(:rooms)).to eq([room1, room2, room3])
      end
    end

    context 'with sorting by capacity in descending order' do
      it 'assigns rooms sorted by capacity to @rooms' do
        get :index, params: { sort: 'capacity', direction: 'desc' }
        expect(assigns(:rooms)).to eq([room3, room1, room2])
      end
    end
  end
end
