# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InstructorsController, type: :controller do
  render_views
  let!(:schedule) { create(:schedule) } # Assuming you have a Schedule factory

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

    context 'without added instructors ' do
      before do
        get :index, params: { schedule_id: schedule.id }
      end

      it 'displays a message saying no instructors added to this schedule' do
        expect(response.body).to include('No instructors added to this schedule!')
      end
    end
    context 'with added instructors ' do
      let!(:instructor1) { create(:instructor, schedule:) } # Associate instructor with the schedule
      let!(:instructor2) { create(:instructor, schedule:) } # Associate another instructor with the schedule
      let!(:course1) { create(:course, schedule:, course_number: '111/708') }
      let!(:course2) { create(:course, schedule:, course_number: '222/708') }
      let!(:preference1) { create(:instructor_preference, instructor: instructor1, course: course1, preference_level: '2') }
      let!(:preference2) { create(:instructor_preference, instructor: instructor2, course: course2, preference_level: '3') }

      it 'assigns all instructors to @instructors' do
        get :index, params: { schedule_id: schedule.id }
        expect(assigns(:instructors)).to match_array([instructor1, instructor2])
      end
      it 'fetches the correct preferences for each instructor' do
        get :index, params: { schedule_id: schedule.id }
        instructor_with_prefs = assigns(:instructors).find { |instructor| instructor.id == instructor1.id }
        expect(instructor_with_prefs.instructor_preferences).to include(preference1)
        expect(instructor_with_prefs.instructor_preferences).not_to include(preference2)

        instructor_with_prefs = assigns(:instructors).find { |instructor| instructor.id == instructor2.id }
        expect(instructor_with_prefs.instructor_preferences).to include(preference2)
      end
    end
  end
end
