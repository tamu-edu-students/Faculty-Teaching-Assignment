# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SchedulesController, type: :controller do
  before do
    allow(controller).to receive(:require_login).and_return(true)
  end

  let!(:schedule1) { create(:schedule) }

  describe 'GET #index' do
    it 'populates an array of schedules' do
      get :index
      expect(assigns(:schedules)).to eq([schedule1])
    end

    it 'filters schedules by search term' do
      other_schedule = create(:schedule, schedule_name: 'Another Schedule')
      get :index, params: { search_by_name: 'Another' }
      expect(assigns(:schedules)).to include(other_schedule)
      expect(assigns(:schedules)).not_to include(schedule1)
    end

    it 'renders the :index template' do
      get :index
      expect(response).to render_template :index
    end
  end

  describe 'GET #show' do
    it 'assigns the requested schedule to @schedule' do
      get :show, params: { id: schedule1.id }
      expect(assigns(:schedule)).to eq(schedule1)
    end

    it 'renders the :show template' do
      get :show, params: { id: schedule1.id }
      expect(response).to render_template :show
    end
  end

  describe 'GET #new' do
    it 'assigns a new schedule to @schedule' do
      get :new
      expect(assigns(:schedule)).to be_a_new(Schedule)
    end

    it 'renders the :new template' do
      get :new
      expect(response).to render_template :new
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      it 'saves the new schedule in the database' do
        expect do
          post :create, params: { schedule: attributes_for(:schedule) }
        end.to change(Schedule, :count).by(1)
      end

      it 'redirects to the schedules index' do
        post :create, params: { schedule: attributes_for(:schedule) }
        expect(response).to redirect_to schedules_url
      end
    end

    context 'with invalid attributes' do
      it 'does not save the new schedule' do
        expect do
          post :create, params: { schedule: attributes_for(:schedule, schedule_name: nil) }
        end.to_not change(Schedule, :count)
      end

      it 're-renders the :new template' do
        post :create, params: { schedule: attributes_for(:schedule, schedule_name: nil) }
        expect(response).to render_template :new
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the schedule' do
      expect do
        delete :destroy, params: { id: schedule1.id }
      end.to change(Schedule, :count).by(-1)
    end

    it 'redirects to schedules index' do
      delete :destroy, params: { id: schedule1.id }
      expect(response).to redirect_to schedules_url
    end
  end
end
