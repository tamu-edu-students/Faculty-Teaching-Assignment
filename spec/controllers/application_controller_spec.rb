# frozen_string_literal: true

# spec/controllers/application_controller_spec.rb
require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  describe '#current_user' do
    context 'when session contains user_id' do
      before do
        @user = User.create!(uid: '12345', provider: 'google_oauth2', email: 'test@example.com', first_name: 'John', last_name: 'Doe')
        session[:user_id] = @user.id
        puts "session[:user_id] = #{session[:user_id]}"
      end

      it 'returns the current user' do
        expect(controller.send(:current_user)).to eq(@user)
      end
    end

    context 'when session does not contain user_id' do
      before do
        session[:user_id] = nil
      end

      it 'returns nil' do
        expect(controller.send(:current_user)).to be_nil
      end
    end
  end

  describe '#logged_in?' do
    context 'when user is logged in' do
      before do
        @user = User.create!(uid: '12345', provider: 'google_oauth2', email: 'test@example.com', first_name: 'John', last_name: 'Doe')
        session[:user_id] = @user.id
      end

      it 'returns the logged in user' do
        expect(controller.send(:logged_in?)).to eq(@user)
      end
    end

    context 'when user is not logged in' do
      before do
        session[:user_id] = nil
      end

      it 'returns nil' do
        expect(controller.send(:logged_in?)).to be nil
      end
    end
  end
end
