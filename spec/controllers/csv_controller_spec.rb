# frozen_string_literal: true

# spec/controllers/csv_controller_spec.rb
require 'rails_helper'

RSpec.describe CsvController, type: :controller do
  before do
    # Create a user and set session user_id as done in your application_controller_spec.rb
    @user = User.create!(uid: '12345', provider: 'google_oauth2', email: 'test@example.com', first_name: 'John',
                         last_name: 'Doe')
    session[:user_id] = @user.id
  end

  let(:file) { fixture_file_upload(Rails.root.join('spec/fixtures/files/test.csv'), 'text/csv') }

  describe 'POST #upload' do
    context 'with a valid CSV file' do
      it "processes the CSV file, sets a success flash, and redirects to the user's page" do
        post :upload, params: { csv_file: file }

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(user_path(@user))  # Redirect to the current user's page
        expect(flash[:notice]).to eq('CSV file uploaded successfully.')
      end
    end

    context 'when no CSV file is selected' do
      it "sets an error flash and redirects to the user's page" do
        post :upload, params: { csv_file: nil }

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(user_path(@user))  # Redirect to the current user's page
        expect(flash[:error]).to eq('Please upload a CSV file.')
      end
    end
  end
end
