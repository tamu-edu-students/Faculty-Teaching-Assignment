# frozen_string_literal: true

# app/controllers/schedules_controller.rb
class SchedulesController < ApplicationController
  before_action :set_schedule, only: %i[show destroy upload_rooms upload_instructors upload_courses]
  def index
    @schedules = Schedule.all

    return unless params[:search_by_name] && params[:search_by_name] != ''

    @schedules = @schedules.where('schedule_name like ?',
                                  "%#{params[:search_by_name]}%")
  end

  def show
    Time.zone = 'America/Chicago'
    @rooms_count = @schedule.rooms.count
    @rooms_last_uploaded = @schedule.rooms.order(created_at: :desc).first&.created_at&.in_time_zone

    @courses_count = @schedule.courses.count
    @courses_last_uploaded = @schedule.courses.order(created_at: :desc).first&.created_at&.in_time_zone

    @instructors_count = @schedule.instructors.count
    @instructors_last_uploaded = @schedule.instructors.order(created_at: :desc).first&.created_at&.in_time_zone
  end

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
      # FIXME: What if the input file is malformed?
      # We've erased our past data with no way to restore it
      # We probably need to create a back up and restore if parsing gives an alert
      @schedule.rooms.destroy_all
      csv_handler = CsvHandler.new
      csv_handler.upload(params[:room_file])
      flash_result = csv_handler.parse_room_csv(@schedule.id)
      flash[flash_result.keys.first] = flash_result.values.first
    else
      flash[:alert] = 'Please upload a CSV file.'
    end
    redirect_to schedule_path(@schedule)
  end

  def upload_instructors
    if params[:instructor_file].present?
      # FIXME: See concern in upload_rooms
      @schedule.instructors.destroy_all
      csv_handler = CsvHandler.new
      csv_handler.upload(params[:instructor_file])
      flash_result = csv_handler.parse_instructor_csv(@schedule.id)
      flash[flash_result.keys.first] = flash_result.values.first
    else
      flash[:alert] = 'Please upload a CSV file.'
    end
    redirect_to schedule_path(@schedule)
  end

  def upload_courses
    if params[:course_file].present?
      # FIXME: See concern in upload_rooms
      Section.where(course_id: @schedule.courses.pluck(:id)).destroy_all
      @schedule.courses.destroy_all
      csv_handler = CsvHandler.new
      csv_handler.upload(params[:course_file])
      flash_result = csv_handler.parse_course_csv(@schedule.id)
      flash[flash_result.keys.first] = flash_result.values.first
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
