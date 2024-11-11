# frozen_string_literal: true

# CSV Handler for uploading room and instructor data
class CsvHandler
  require 'csv'

  def upload(file)
    @file = file
  end

  def parse_room_csv(schedule_id)
    ActiveRecord::Base.transaction do
      room_data = CSV.parse(@file.read, headers: true)
      room_data.each do |row|
        Room.create!(
          schedule_id:,
          campus: row['campus'],
          building_code: row['building_code'],
          room_number: row['room_number'],
          capacity: row['capacity'].to_i,
          is_lecture_hall: row['is_lecture_hall'] == 'True',
          is_learning_studio: row['is_learning_studio'] == 'True',
          is_lab: row['is_lab'] == 'True',
          is_active: row['is_active'] == 'True',
          comments: row['comments']
        )
      end
    end
    # Flash data to be received by controller
    { notice: 'Rooms successfully uploaded.' }
  rescue StandardError => e
    { alert: "There was an error uploading the CSV file: #{e.message}" }
  end

  def parse_instructor_csv(schedule_id)
    ActiveRecord::Base.transaction do
      schedule = Schedule.find(schedule_id)
      instructor_data = CSV.parse(@file.read)
      actual_headers = instructor_data[1]

      # FIXME: This should be removed before go-live. This is to add missing data to the csv so that we can work with it
      missing_names = !actual_headers.include?('First Name') || !actual_headers.include?('Last Name') || !actual_headers.include?('Email')
      instructor_data, actual_headers = add_missing_data(instructor_data, actual_headers) if missing_names

      required_headers = [
        'anonimized ID',
        'First Name',
        'Last Name',
        'Email',
        'Teaching before 9:00 am.',
        'Teaching after 3:00 pm.',
        'Middle Name',
        'Number of courses to assign',
        'Is there anything else we should be aware of regarding your teaching load (special course reduction, ...)' # Optional: Include if needed
      ]

      missing_headers = required_headers - actual_headers
      return { alert: "Missing required headers: #{missing_headers.join(', ')}" } unless missing_headers.empty?

      preferences_to_upload = []
      courses_with_preferences = []
      missing_courses = []
      instructor_data[2..].each_with_index do |row, _index|
        next if row.join.include?('ImportId')

        # Extracting values and checking for nulls
        id_number = row[actual_headers.index('anonimized ID')]
        first_name = row[actual_headers.index('First Name')]
        last_name = row[actual_headers.index('Last Name')]
        middle_name = row[actual_headers.index('Middle Name')]
        email = row[actual_headers.index('Email')]
        before_9 = row[actual_headers.index('Teaching before 9:00 am.')]
        after_3 = row[actual_headers.index('Teaching after 3:00 pm.')]
        beaware_of = row[actual_headers.index(
          'Is there anything else we should be aware of regarding your teaching load (special course reduction, ...)'
        )]
        course_load = row[actual_headers.index('Number of courses to assign')]

        instructor_data = {
          schedule_id:,
          id_number:,
          first_name:,
          last_name:,
          middle_name:,
          email:,
          before_9:,
          after_3:,
          beaware_of:,
          max_course_load: course_load
        }
        instructor = Instructor.create(instructor_data)
        row.each_with_index do |_cell, col_index|
          # Match headers that contain "capability/interest" and "course"
          match = actual_headers[col_index].match(%r{.*capability/interest.*course.*- (\d+(?:/\d+)?) - (.+)}i)
          next unless match

          course_number = match[1]
          course = schedule.courses.find_by(course_number:)
          if course.nil?
            first_part, last_part = course_number.split('/')
            
            # Attempt to find by first or last part, and update course_number accordingly
            course = schedule.courses.find_by(course_number: first_part) || schedule.courses.find_by(course_number: last_part)
            course_number = course&.course_number if course
          end
          
          if course
            # Store valid preferences temporarily
            preferences_to_upload << {
              instructor_id: instructor.id,
              course: course,
              preference_level: row[col_index]
            }
            courses_with_preferences << course_number
          end
        end
      end
      missing_courses = schedule.courses.pluck(:course_number).uniq - courses_with_preferences.uniq
      if missing_courses.any?
        instructors = schedule.instructors.pluck(:id).uniq
        instructors.each do |instructor_id|
          missing_courses.each do |course|
            preferences_to_upload << {
              instructor_id:,
              course: schedule.courses.find_by(course_number: course),
              preference_level: 3
            } # Default preference level for missing courses
          end
        end
      end

      # Create instructor preferences if all courses are valid
      preferences_to_upload.each do |preference|
        InstructorPreference.create(preference)
      end
    end
    { notice: 'Instructors and Preferences successfully uploaded.' }
  rescue StandardError => e
    { alert: "There was an error uploading the CSV file: #{e.message}" }
  end

  def parse_course_csv(schedule_id)
    ActiveRecord::Base.transaction do
      course_data = CSV.parse(@file.read)
      actual_headers = course_data[0]
      required_headers = [
        'Class',
        'Max. Seats',
        'Lecture Type',
        '#Labs',
        'Section number',
        'Seat Split'
      ]

      missing_headers = required_headers - actual_headers
      return { alert: "Missing required headers: #{missing_headers.join(', ')}" } unless missing_headers.empty?

      course_data[1..].each do |row|
        # Extracting values and checking for nulls
        course_number = row[actual_headers.index('Class')]
        max_seats = row[actual_headers.index('Max. Seats')]
        labs = row[actual_headers.index('#Labs')]
        lecture_type = row[actual_headers.index('Lecture Type')]
        section_number = row[actual_headers.index('Section number')]
        seats_allocated = row[actual_headers.index('Seat Split')]

        course_data = {
          schedule_id:,
          course_number:,
          max_seats: max_seats.to_i,
          lecture_type:,
          num_labs: labs.to_i
        }

        course = Course.create(course_data)

        section_array = section_number.split(',')
        seats_array = seats_allocated.split(',')

        section_array.each_with_index do |section, index|
          section_data = {
            course_id: course.id,
            section_number: section,
            seats_alloted: seats_array[index].to_i
          }

          Section.create(section_data)
        end
      end
    end
    { notice: 'Courses successfully uploaded.' }
  rescue StandardError => e
    { alert: "There was an error uploading the CSV file: #{e.message}" }
  end

  private

  # Function to add random names and emails to the csv
  def add_missing_data(instructor_data, actual_headers)
    # Modify the header row
    actual_headers += ['First Name', 'Middle Name', 'Last Name', 'Email']

    # Update the actual headers in instructor_data
    instructor_data[1] = actual_headers

    # Add random names and emails to each subsequent row
    instructor_data[2..].each_with_index do |row, index|
      # Generate random names
      random_first_name = random_name
      random_last_name = random_name
      random_email = generate_email(random_first_name, random_last_name)

      # Append random names and email to the row
      new_row = row + [random_first_name, '', random_last_name, random_email]
      instructor_data[index + 2] = new_row
    end
    [instructor_data, actual_headers]
  end

  # Function to generate a random name
  def random_name
    length = 6 # Adjust the length of the name as needed
    letters = ('A'..'Z').to_a + ('a'..'z').to_a
    Array.new(length) { letters.sample }.join.capitalize
  end

  # Function to generate a random email
  def generate_email(first_name, last_name)
    "#{first_name.downcase}.#{last_name.downcase}@example.com"
  end
end
