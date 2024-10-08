# frozen_string_literal: true

# spec/controllers/sessions_controller_spec.rb
require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  # before(:all) do
  #   @user = User.create!(
  #     uid: '12345',
  #     provider: 'google_oauth2',
  #     email: 'test@example.com',
  #     first_name: 'John', last_name: 'Doe'
  #   )
  # end
  # after(:all) do
  #   User.destroy_all
  # end
  describe 'GET #logout' do
    before do
      @user = User.create!(uid: '12345', provider: 'google_oauth2', email: 'test@example.com', first_name: 'John',
                           last_name: 'Doe')
      session[:user_id] = @user.id
    end
    it 'resets the session' do
      get :logout
      expect(session[:user_id]).to be_nil
    end
    after do
      User.destroy_all
    end

    it 'redirects to the welcome path with a notice' do
      get :logout
      expect(response).to redirect_to(welcome_path)
      expect(flash[:notice]).to eq('You are logged out')
    end
  end
  describe 'GET #omniauth' do
    let(:auth_hash) do
      {
        'uid' => '12345', 'provider' => 'google_oauth2',
        'info' => { 'email' => 'test@example.com', 'name' => 'John Doe' }
      }
    end
    before do
      request.env['omniauth.auth'] = OmniAuth::AuthHash.new(auth_hash)
    end
    it 'finds or creates a user and sets the session user_id' do
      expect { get :omniauth }.to change(User, :count).by(1)
      user = User.last
      expect(user.uid).to eq('12345')
      expect(user.email).to eq('test@example.com')
      expect(user.first_name).to eq('John')
      expect(user.last_name).to eq('Doe')
    end

    it 'redirects to the root path' do
      get :omniauth
      expect(response).to redirect_to(user_path(User.last))
    end

    it 'sets a flash notice' do
      get :omniauth
      expect(flash[:notice]).to eq('You are logged in')
    end
  end
end
