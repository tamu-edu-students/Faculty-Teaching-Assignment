# frozen_string_literal: true

# app/controllers/schedules_controller.rb
class SchedulesController < ApplicationController
  before_action :set_schedule, only: %i[show destroy]
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

  # Only allow a list of trusted parameters through.
  def schedule_params
    params.require(:schedule).permit(:schedule_name, :semester_name)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_schedule
    @schedule = Schedule.find(params[:id])
  end
end
