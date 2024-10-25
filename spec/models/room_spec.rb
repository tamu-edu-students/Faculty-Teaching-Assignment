# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Room, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:building_code) }
    it { should validate_presence_of(:room_number) }
    it { should validate_presence_of(:capacity) }
    it { should validate_numericality_of(:capacity).only_integer }
  end

  describe 'default values' do
    it 'has default is_active as true' do
      @room = Room.new(
        campus: :CS,
        building_code: 'A102',
        room_number: '203',
        capacity: 100,
        is_lecture_hall: true,
        is_learning_studio: false,
        is_lab: true,
        is_active: true,
        comments: 'Lecture hall with lab facilities'
      )
      expect(@room.is_active).to eq(true)
    end
  end
end
