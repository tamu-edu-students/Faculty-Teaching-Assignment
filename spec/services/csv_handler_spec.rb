# frozen_string_literal: true

# spec/services/csv_handler_spec.rb
require 'rails_helper'

RSpec.describe CsvHandler do
  let(:schedule) { create(:schedule) }
  let(:valid_room_csv) { File.read(Rails.root.join('spec', 'fixtures', 'rooms', 'rooms_valid.csv')) }
  let(:invalid_room_csv) { File.read(Rails.root.join('spec', 'fixtures', 'rooms', 'rooms_invalid.csv')) }
  let(:valid_instructor_csv) { File.read(Rails.root.join('spec', 'fixtures', 'instructors', 'instructors_valid.csv')) }
  let(:invalid_instructor_csv) { File.read(Rails.root.join('spec', 'fixtures', 'instructors', 'instructors_missing_headers.csv')) }
  let(:valid_course_csv) { File.read(Rails.root.join('spec', 'fixtures', 'courses', 'Course_list_valid.csv')) }
  let(:invalid_course_csv) { File.read(Rails.root.join('spec', 'fixtures', 'courses', 'Course_list_invalid.csv')) }

  describe '#initialize' do
    it 'initializes with a file' do
      handler = CsvHandler.new
      handler.upload(valid_room_csv)
      expect(handler.instance_variable_get(:@file)).to eq(valid_room_csv)
    end
  end

  describe '#parse_room_csv' do
    context 'with valid data' do
      it 'creates room records' do
        handler = CsvHandler.new
        handler.upload(StringIO.new(valid_room_csv))
        handler.parse_room_csv(schedule.id)
        expect(Room.count).to eq(10)
      end

      it 'returns a success message' do
        handler = CsvHandler.new
        handler.upload(StringIO.new(valid_room_csv))
        result = handler.parse_room_csv(schedule.id)
        expect(result[:notice]).to eq('Rooms successfully uploaded.')
      end
    end

    context 'with invalid data' do
      it 'prints an alert' do
        handler = CsvHandler.new
        handler.upload(StringIO.new(invalid_room_csv))
        result = handler.parse_room_csv(schedule.id)
        expect(result[:alert]).to include('There was an error uploading the CSV file')
      end
    end
  end

  describe '#parse_instructor_csv' do
    context 'with valid data' do
      it 'creates instructor records' do
        handler = CsvHandler.new
        handler.upload(StringIO.new(valid_instructor_csv))
        handler.parse_instructor_csv(schedule.id)
        expect(Instructor.count).to eq(4)
      end

      it 'returns a success message' do
        handler = CsvHandler.new
        handler.upload(StringIO.new(valid_instructor_csv))
        result = handler.parse_instructor_csv(schedule.id)
        expect(result[:notice]).to eq('Instructors successfully uploaded.')
      end
    end

    context 'with missing header data' do
      it 'prints an alert' do
        handler = CsvHandler.new
        handler.upload(StringIO.new(invalid_instructor_csv))
        result = handler.parse_instructor_csv(schedule.id)
        expect(result[:alert]).to include('Missing required headers')
      end
    end
  end

  describe '#parse_course_csv' do
    context 'with valid data' do
      it 'creates course records' do
        handler = CsvHandler.new
        handler.upload(StringIO.new(valid_course_csv))
        handler.parse_course_csv(schedule.id)
        expect(Course.count).to eq(10)
      end

      it 'returns a success message' do
        handler = CsvHandler.new
        handler.upload(StringIO.new(valid_course_csv))
        result = handler.parse_course_csv(schedule.id)
        expect(result[:notice]).to eq('Courses successfully uploaded.')
      end
    end

    context 'with invalid data' do
      it 'prints an alert' do
        handler = CsvHandler.new
        handler.upload(StringIO.new(invalid_course_csv))
        result = handler.parse_course_csv(schedule.id)
        expect(result[:alert]).to include('Missing required headers: Class, Max. Seats, Lecture Type, #Labs, Section number, Seat Split')
      end
    end
  end
end
