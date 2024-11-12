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
      before do
        handler = CsvHandler.new
        handler.upload(StringIO.new(valid_course_csv))
        handler.parse_course_csv(schedule.id)

        handler = CsvHandler.new
        handler.upload(StringIO.new(valid_instructor_csv))
        @result = handler.parse_instructor_csv(schedule.id)
      end
      it 'creates instructor records' do
        expect(Instructor.count).to eq(3) # The dummy CSV has 3 instructors
      end

      it 'creates instructor prefrences with correct values' do
        expect(InstructorPreference.count).to eq(3 * 6) # 3 instructors with 2 valid preferences each and 4 extra course in the courses table
        instructor = Instructor.find_by(id_number: 2_755_728)
        expect(instructor).not_to be_nil
        preferences = InstructorPreference.where(instructor_id: instructor.id)
        expect(preferences.count).to eq(6)
        course = Course.find_by(course_number: '120')
        preference1 = preferences.find_by(course:)
        expect(preference1.preference_level).to eq(2)
        course = Course.find_by(course_number: '435/735/735D')
        preference1 = preferences.find_by(course:)
        expect(preference1.preference_level).to eq(3)
        # Check split courses set
        course = Course.find_by(course_number: '410')
        preference1 = preferences.find_by(course:)
        expect(preference1.preference_level).to eq(1)
      end

      it 'returns a success message' do
        expect(@result[:notice]).to eq('Instructors and Preferences successfully uploaded.')
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
        expect(Course.count).to eq(11)
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
