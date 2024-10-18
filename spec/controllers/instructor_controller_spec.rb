# spec/controllers/instructors_controller_spec.rb
require 'rails_helper'

RSpec.describe InstructorsController, type: :controller do
  before do
    Instructor.delete_all
    allow(controller).to receive(:require_login).and_return(true)
  end
  
  let!(:instructor1) { Instructor.create!(first_name: 'John', last_name: 'Doe', id_number: 566) }
  let!(:instructor2) { Instructor.create!(first_name: 'Jane', last_name: 'Doe', id_number: 577) }

  describe 'GET #index' do
    it 'assigns @instructors and renders the index template' do
      get :index  # Make a GET request to the index action

      # Ensure that the @instructors variable is set correctly
      expect(assigns(:instructors)).to match_array([instructor1, instructor2])
      
      # Check that the index template is rendered
      expect(response).to render_template(:index)
    end
  end
end
