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
      it "processes the CSV file and sets a success flag" do
        post :upload, params: { csv_file: file }
        expect(flash[:notice]).to eq('File uploaded successfully')
      end
    end

    context 'when no CSV file is selected' do
      it "sets an error flash" do
        post :upload, params: { csv_file: nil }
        expect(flash[:error]).to eq('Please upload a CSV file.')
      end
    end
  end
end
