# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CoursesController, type: :controller do
  render_views
  let(:user) { create(:user) }
  let(:schedule) { create(:schedule, user:) }
  let(:course) { create(:course, schedule:, hide: false) }

  before do
    allow(controller).to receive(:logged_in?).and_return(true)
    controller.instance_variable_set(:@current_user, user)
    session[:user_id] = user.id
  end

  describe 'GET #index' do
    it 'incorrect schedule id' do
      get :index, params: { schedule_id: (schedule.id + 1) }
      expect(flash[:alert]).to eq('Schedule not found.')
    end

    context 'without added courses ' do
      before do
        get :index, params: { schedule_id: schedule.id }
      end

      it 'try seeing the courses' do
        expect(assigns(:courses)).to be_empty
      end

      it 'displays a message saying no courses added to this schedule' do
        expect(response.body).to include('No courses added to this schedule!')
      end
    end
    context 'with added courses ' do
      let!(:course1) do
        create(:course, course_number: '120', section_numbers: '500', max_seats: 90, lecture_type: 'Hybrid', num_labs: 3, schedule_id: schedule.id)
      end
      let!(:course2) do
        create(:course, course_number: '320', section_numbers: '501', max_seats: 120, lecture_type: 'Online', num_labs: 2, schedule_id: schedule.id)
      end
      let!(:course3) do
        create(:course, course_number: '400', section_numbers: '502', max_seats: 150, lecture_type: 'F2F', num_labs: 1, schedule_id: schedule.id,
                        hide: true)
      end

      context 'without any sorting' do
        it 'assigns all active courses to @courses' do
          get :index, params: { schedule_id: schedule.id }
          expect(assigns(:courses)).to match_array([course1, course2])
        end

        it 'assigns all hidden courses to @courses' do
          get :index, params: { schedule_id: schedule.id, show_hidden: 'true' }
          expect(assigns(:courses)).to match_array([course3])
        end
      end

      context 'with sorting by course_number' do
        it 'assigns courses sorted by course_number ascending  to @courses' do
          get :index, params: { schedule_id: schedule.id, sort: 'course_number', direction: 'asc' }
          expect(assigns(:courses)).to eq([course1, course2])
        end
        it 'assigns courses sorted by course_number descending  to @courses' do
          get :index, params: { schedule_id: schedule.id, sort: 'course_number', direction: 'desc' }
          expect(assigns(:courses)).to eq([course2, course1])
        end
      end

      context 'with sorting by max_seats' do
        it 'assigns courses sorted by max_seats ascending  to @courses' do
          get :index, params: { schedule_id: schedule.id, sort: 'max_seats', direction: 'asc' }
          expect(assigns(:courses)).to eq([course1, course2])
        end
        it 'assigns courses sorted by max_seats descending  to @courses' do
          get :index, params: { schedule_id: schedule.id, sort: 'max_seats', direction: 'desc' }
          expect(assigns(:courses)).to eq([course2, course1])
        end
      end

      context 'with sorting by lecture_type' do
        it 'assigns courses sorted by lecture_type ascending  to @courses' do
          get :index, params: { schedule_id: schedule.id, sort: 'lecture_type', direction: 'asc' }
          expect(assigns(:courses)).to eq([course1, course2])
        end
        it 'assigns courses sorted by lecture_type descending  to @courses' do
          get :index, params: { schedule_id: schedule.id, sort: 'lecture_type', direction: 'desc' }
          expect(assigns(:courses)).to eq([course2, course1])
        end
      end

      context 'with sorting by num_labs' do
        it 'assigns courses sorted by num_labs ascending  to @courses' do
          get :index, params: { schedule_id: schedule.id, sort: 'num_labs', direction: 'asc' }
          expect(assigns(:courses)).to eq([course2, course1])
        end
        it 'assigns courses sorted by num_labs descending  to @courses' do
          get :index, params: { schedule_id: schedule.id, sort: 'num_labs', direction: 'desc' }
          expect(assigns(:courses)).to eq([course1, course2])
        end
      end
    end
  end

  describe 'PATCH #toggle_hide' do
    context 'when course has no associated room bookings' do
      it 'toggles the hide attribute and redirects with a success notice' do
        patch :toggle_hide, params: { schedule_id: schedule.id, id: course.id }

        course.reload
        expect(flash[:notice]).to eq('Course updated successfully.')
        expect(course.hide).to eq(true)
        expect(response).to redirect_to("/schedules/#{schedule.id}/courses")
      end
    end

    context 'when course has associated room bookings' do
      let!(:room_booking) { create(:room_booking, course_id: course.id) }

      it 'does not toggle the hide attribute and redirects with an alert' do
        patch :toggle_hide, params: { schedule_id: schedule.id, id: course.id }

        course.reload
        expect(course.hide).to eq(false)
        expect(response).to redirect_to("/schedules/#{schedule.id}/courses")
        expect(flash[:alert]).to eq('Cannot hide course because it has associated room bookings.')
      end
    end

    context 'when course update fails' do
      before do
        allow_any_instance_of(Course).to receive(:update).and_return(false)
      end

      it 'renders an error message with status unprocessable_entity' do
        patch :toggle_hide, params: { schedule_id: schedule.id, id: course.id }

        expect(response.status).to eq(422)
        expect(JSON.parse(response.body)['error']).to eq('Failed to update course hide status')
      end
    end
  end
end
