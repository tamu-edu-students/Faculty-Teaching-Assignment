# frozen_string_literal: true

require 'csv'

# app/controllers/schedules_controller.rb
class SchedulesController < ApplicationController
  before_action :set_schedule, only: %i[show destroy upload_rooms upload_instructors upload_courses]
  def index
    @schedules = Schedule.all

    return unless params[:search_by_name] && params[:search_by_name] != ''

    @schedules = @schedules.where('schedule_name like ?',
                                  "%#{params[:search_by_name]}%")
  end

  def show; end

  # GET /schedules/new
  def new
    @schedule = Schedule.new
  end

  def create
    @schedule = Schedule.new(schedule_params)

    respond_to do |format|
      if @schedule.save
        format.html { redirect_to schedules_url, notice: 'Schedule was successfully created.' }
        format.json { render :show, status: :created, location: @schedule }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @schedule.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @schedule.destroy!

    respond_to do |format|
      format.html { redirect_to schedules_url, notice: 'Schedule was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  def upload_rooms
    if params[:room_file].present?
      begin
        ActiveRecord::Base.transaction do
          room_data = CSV.read(params[:room_file].path, headers: true)

          @schedule.rooms.destroy_all

          room_data.each do |row|
            Room.create!(
              schedule_id: @schedule.id,
              campus: row['campus'],
              building_code: row['building_code'],
              room_number: row['room_number'],
              capacity: row['capacity'],
              is_lecture_hall: row['is_lecture_hall'] == 'True',
              is_learning_studio: row['is_learning_studio'] == 'True',
              is_lab: row['is_lab'] == 'True',
              is_active: row['is_active'] == 'True',
              comments: row['comments']
            )
          end
        end
        flash[:notice] = 'Rooms successfully uploaded.'
      rescue StandardError => e
        flash[:alert] = "There was an error uploading the CSV file: #{e.message}"
        raise e
      end
    else
      flash[:alert] = 'Please upload a CSV file.'
    end

    redirect_to schedule_path(@schedule)
  end

  def upload_instructors
    if params[:instructor_file].present?
      begin
        ActiveRecord::Base.transaction do
          instructor_data = CSV.read(params[:instructor_file].path)

          @schedule.instructors.destroy_all
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
            flash[:alert] = "Missing required headers: #{missing_headers.join(', ')}"
            redirect_to schedule_path(@schedule) and return
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
              schedule_id: @schedule.id,
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
        flash[:notice] = 'Instructors successfully uploaded.'
      rescue StandardError => e
        flash[:alert] = "There was an error uploading the CSV file: #{e.message}"
        raise e
      end
    else
      flash[:alert] = 'Please upload a CSV file.'
    end
    redirect_to schedule_path(@schedule)
  end


  def upload_courses
    if params[:course_file].present?
      begin
        ActiveRecord::Base.transaction do
          course_data = CSV.read(params[:course_file].path)

          # @schedule.courses.destroy_all
          actual_headers = course_data[0]

          required_headers = [
            'Class',
            'Title',
            'Description',
            'Credits',
            'Max. Seats',
            '#Labs',
            'Section number'
              ]

          missing_headers = required_headers - actual_headers
          unless missing_headers.empty?
            flash[:alert] = "Missing required headers: #{missing_headers.join(', ')}"
            redirect_to schedule_path(@schedule) and return
          end

          course_data[1..].each do |row|
            # Extracting values and checking for nulls
            course_number = row[actual_headers.index('Class')]
            title = row[actual_headers.index('Title')]
            description = row[actual_headers.index('Description')]
            credits = row[actual_headers.index('Credits')]
            max_seats = row[actual_headers.index('Max. Seats')]
            labs = row[actual_headers.index('#Labs')]
            section_number = row[actual_headers.index('Section number')]
            has_lab = labs.to_i > 0
            num_sections = section_number.split(',').count

            course_data = {
              course_number: course_number,
              title: title,
              description: description,
              credits: credits,
              has_lab: has_lab
            }
            course = Course.create(course_data)

            teaching_plan_data = {
              schedule_id: @schedule.id,
              course_id: course.id,
              num_sections: num_sections,
              num_students: max_seats
            }
            TeachingPlan.create(teaching_plan_data)

            section_number.split(',').each do |section|
              section_data = {
                schedule_id: @schedule.id,
                room_id: 198,
                course_id: course.id, 
                section_number: section.to_i,
                size: max_seats
              }
              CourseSection.create(section_data)
            end

            
          end
        end
        flash[:notice] = 'Courses successfully uploaded.'
      rescue StandardError => e
        flash[:alert] = "There was an error uploading the CSV file: #{e.message}"
        raise e
      end
    else
      flash[:alert] = 'Please upload a CSV file.'
    end
    redirect_to schedule_path(@schedule)
  end
  # Only allow a list of trusted parameters through.
  def schedule_params
    params.require(:schedule).permit(:schedule_name, :semester_name, :room_file, :instructor_file)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_schedule
    @schedule = Schedule.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = 'Schedule not found.'
    redirect_to schedules_path
  end
end
