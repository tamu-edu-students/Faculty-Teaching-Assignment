# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CoursesController, type: :controller do
  render_views
  let(:schedule) { Schedule.create!(schedule_name: 'Fall Semester', semester_name: '2024') }

  describe 'GET #index' do
    before do
      @user = User.create!(uid: '12345', provider: 'google_oauth2', email: 'test@example.com', first_name: 'John',
                           last_name: 'Doe')
      allow(controller).to receive(:logged_in?).and_return(true)
      controller.instance_variable_set(:@current_user, @user)
    end

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
        create(:course, course_number: '120', max_seats: 90, lecture_type: 'Hybrid', num_labs: 3, schedule_id: schedule.id)
      end
      let!(:section11) do
        create(:section, section_number: '500', seats_alloted: 30, course_id: course1.id)
      end
      let!(:section12) do
        create(:section, section_number: '501', seats_alloted: 30, course_id: course1.id)
      end
      let!(:section13) do
        create(:section, section_number: '502', seats_alloted: 30, course_id: course1.id)
      end
      let!(:course2) do
        create(:course, course_number: '320', max_seats: 120, lecture_type: 'Online', num_labs: 2, schedule_id: schedule.id)
      end
      let!(:section21) do
        create(:section, section_number: '500', seats_alloted: 60, course_id: course2.id)
      end
      let!(:section22) do
        create(:section, section_number: '501', seats_alloted: 60, course_id: course2.id)
      end
      let!(:course3) do
        create(:course, course_number: '400', max_seats: 150, lecture_type: 'F2F', num_labs: 1, schedule_id: schedule.id)
      end
      let!(:section31) do
        create(:section, section_number: '500', seats_alloted: 150, course_id: course3.id)
      end

      context 'without any sorting' do
        it 'assigns all courses to @courses' do
          get :index, params: { schedule_id: schedule.id }
          expect(assigns(:courses)).to match_array([course1, course2, course3])
        end
      end

      context 'with sorting by course_number' do
        it 'assigns courses sorted by course_number ascending  to @courses' do
          get :index, params: { schedule_id: schedule.id, sort: 'course_number', direction: 'asc' }
          expect(assigns(:courses)).to eq([course1, course2, course3])
        end
        it 'assigns courses sorted by course_number descending  to @courses' do
          get :index, params: { schedule_id: schedule.id, sort: 'course_number', direction: 'desc' }
          expect(assigns(:courses)).to eq([course3, course2, course1])
        end
      end

      context 'with sorting by max_seats' do
        it 'assigns courses sorted by max_seats ascending  to @courses' do
          get :index, params: { schedule_id: schedule.id, sort: 'max_seats', direction: 'asc' }
          expect(assigns(:courses)).to eq([course1, course2, course3])
        end
        it 'assigns courses sorted by max_seats descending  to @courses' do
          get :index, params: { schedule_id: schedule.id, sort: 'max_seats', direction: 'desc' }
          expect(assigns(:courses)).to eq([course3, course2, course1])
        end
      end

      context 'with sorting by lecture_type' do
        it 'assigns courses sorted by lecture_type ascending  to @courses' do
          get :index, params: { schedule_id: schedule.id, sort: 'lecture_type', direction: 'asc' }
          expect(assigns(:courses)).to eq([course3, course1, course2])
        end
        it 'assigns courses sorted by lecture_type descending  to @courses' do
          get :index, params: { schedule_id: schedule.id, sort: 'lecture_type', direction: 'desc' }
          expect(assigns(:courses)).to eq([course2, course1, course3])
        end
      end

      context 'with sorting by num_labs' do
        it 'assigns courses sorted by num_labs ascending  to @courses' do
          get :index, params: { schedule_id: schedule.id, sort: 'num_labs', direction: 'asc' }
          expect(assigns(:courses)).to eq([course3, course2, course1])
        end
        it 'assigns courses sorted by num_labs descending  to @courses' do
          get :index, params: { schedule_id: schedule.id, sort: 'num_labs', direction: 'desc' }
          expect(assigns(:courses)).to eq([course1, course2, course3])
        end
      end
    end
  end
end
