# frozen_string_literal: true

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

  def generate_schedule
    # Join room data together
    active_rooms = Room.where(is_active: true)
    building_codes = active_rooms.map{|room| room['building_code']}
    room_numbers = active_rooms.map{|room| room['room_number']}
    rooms = building_codes.zip(room_numbers).map { |bld, num| "#{bld} #{num}" }
    capacities = active_rooms.map{|room| room['capacity']}
    
    times = TimeSlot.pluck(:day, :start_time, :end_time)
    
    professors = Instructor.pluck(:last_name, :first_name).map{|n| "#{n[0]}, #{n[1]}"}
    classes = (0...professors.length).to_a
    enrollments = Array.new(classes.length) { rand(20..30) }

    # TODO: Garbage value for now
    locks = [[0,0,0]]

    # TODO: This needs to be a num_profs x num_classes matrix
    # However, we can only run HA on square matrices
    # We'll need to duplicate professors according to their contracted teaching load
    unhappiness_matrix = Array.new(professors.length) {Array.new(classes.length) { rand(1..10)}}
    assignment = ScheduleSolver.solve(classes, rooms, times, professors, capacities, enrollments, locks, unhappiness_matrix)


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
