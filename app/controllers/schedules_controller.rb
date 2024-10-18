# frozen_string_literal: true

require 'csv'

# app/controllers/schedules_controller.rb
class SchedulesController < ApplicationController
  before_action :set_schedule, only: %i[show destroy upload_rooms upload_instructors]
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
    if params[:file].present?
      begin
        ActiveRecord::Base.transaction do
          room_data = CSV.read(params[:file].path, headers: true)

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
    if params[:file].present?
      begin
        ActiveRecord::Base.transaction do
          instructor_data = CSV.read(params[:file].path, headers: true)
         
          @schedule.instructors.destroy_all
          actual_headers = instructor_data[1] 
          instructor_data[2..].each do |row|
            instructor_data = {
                schedule_id: @schedule.id,
                id_number: row[actual_headers.index('anonimized ID')],
                first_name: row[actual_headers.index('First Name')],
                last_name: row[actual_headers.index('Last Name')],
                middle_name: row[actual_headers.index('Middle Name')],
                email: row[actual_headers.index('Email')],
                before_9: row[actual_headers.index('Teaching before 9:00 am.')],
                after_3: row[actual_headers.index('Teaching after 3:00 pm.')],
                beaware_of: row[actual_headers.index('Is there anything else we should be aware of regarding your teaching load (special course reduction, ...)')]
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

  # Only allow a list of trusted parameters through.
  def schedule_params
    params.require(:schedule).permit(:schedule_name, :semester_name, :room_csv)
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
