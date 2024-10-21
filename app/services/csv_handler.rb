# frozen_string_literal: true

class CSVHandler
  require 'csv'

  def upload(file)
    @file = file
  end

  def parse_room_csv(schedule_id)
    begin
      ActiveRecord::Base.transaction do
        room_data = CSV.parse(@file.read, headers: true)
        room_data.each do |row|
          Room.create!(
            schedule_id: schedule_id,
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
      return { notice: 'Rooms successfully uploaded.' }
    rescue StandardError => e
      return { alert: "There was an error uploading the CSV file: #{e.message}" }
    end
  end

  def parse_instructor_csv(schedule_id)
    begin
      ActiveRecord::Base.transaction do
        instructor_data = CSV.parse(@file.read)
        actual_headers = instructor_data[1]
        required_headers = [
          'anonimized ID',
          'First Name',
          'Last Name',
          'Email',
          'Teaching before 9:00 am.',
          'Teaching after 3:00 pm.',
          'Middle Name',
          'Is there anything else we should be aware of regarding your teaching load (special course reduction, ...)' # Optional: Include if needed
        ]

        missing_headers = required_headers - actual_headers
        unless missing_headers.empty?
          return {alert: "Missing required headers: #{missing_headers.join(', ')}"}
        end

        instructor_data[2..].each do |row|
          # Extracting values and checking for nulls
          id_number = row[actual_headers.index('anonimized ID')]
          first_name = row[actual_headers.index('First Name')]
          last_name = row[actual_headers.index('Last Name')]
          middle_name = row[actual_headers.index('Middle Name')]
          email = row[actual_headers.index('Email')]
          before_9 = row[actual_headers.index('Teaching before 9:00 am.')]
          after_3 = row[actual_headers.index('Teaching after 3:00 pm.')]
          beaware_of = row[actual_headers.index('Is there anything else we should be aware of regarding your teaching load (special course reduction, ...)')]

          instructor_data = {
            schedule_id: schedule_id,
            id_number: id_number,
            first_name: first_name,
            last_name: last_name,
            middle_name: middle_name,
            email: email,
            before_9: before_9,
            after_3: after_3,
            beaware_of: beaware_of
          }

          Instructor.create(instructor_data)
        end
      end
      return {notice: 'Instructors successfully uploaded.'}
    rescue StandardError => e
      return {alert: "There was an error uploading the CSV file: #{e.message}"}
    end
  end
    
end
