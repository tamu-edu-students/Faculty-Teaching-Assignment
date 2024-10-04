# frozen_string_literal: true

# spec/controllers/welcome_controller_spec.rb
require 'rails_helper'

RSpec.describe WelcomeController, type: :controller do
  describe 'GET #index' do
    context 'when user is logged in' do
      before do
        @user = User.create!(uid: '12345', provider: 'google_oauth2', email: 'test@example.com', first_name: 'John',
                             last_name: 'Doe')
        allow(controller).to receive(:logged_in?).and_return(true)
        controller.instance_variable_set(:@current_user, @user)
      end

      it 'redirects to the user path with a welcome notice' do
        get :index
        expect(response).to redirect_to(user_path(@user))
        expect(flash[:notice]).to eq('Welcome back, John!')
      end
    end

    context 'when user is not logged in' do
      before do
        allow(controller).to receive(:logged_in?).and_return(false)
      end

      it 'renders the index template' do
        get :index
        expect(response).to render_template(:index)
      end
    end
  end
end
