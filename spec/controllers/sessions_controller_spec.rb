# frozen_string_literal: true

# spec/controllers/sessions_controller_spec.rb
require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  before(:all) do
    @user = User.create!(
      uid: '12345',
      provider: 'google_oauth2',
      email: 'test@example.com',
      first_name: 'John', last_name: 'Doe'
    )
  end
  after(:all) do
    User.destroy_all
  end
  describe 'GET #logout' do
    before do
      session[:user_id] = @user.id
    end
    it 'resets the session' do
      get :logout
      expect(session[:user_id]).to be_nil
    end

    it 'redirects to the welcome path with a notice' do
      get :logout
      expect(response).to redirect_to(welcome_path)
      expect(flash[:notice]).to eq('You are logged out')
    end
  end
end
