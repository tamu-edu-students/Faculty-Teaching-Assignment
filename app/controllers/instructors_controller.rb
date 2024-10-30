# frozen_string_literal: true

# Controller for Instructors
class InstructorsController < ApplicationController
  before_action :set_schedule, only: [:index]
  helper_method :sort_column, :sort_direction
  def index
    @schedule = Schedule.find(params[:schedule_id])
    @instructors = @schedule.instructors.includes(:instructor_preferences)

    direction = params[:direction] == 'desc' ? 'desc' : 'asc'
    @instructors = @instructors.order("#{sort_column} #{direction}")
  end

  private

  def set_schedule
    @schedule = Schedule.find(params[:schedule_id]) if params[:schedule_id]
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = 'Schedule not found.'
    redirect_to schedules_path
  end

  def sort_column
    Instructor.column_names.include?(params[:sort]) ? params[:sort] : 'first_name'
  end

  # Define the sorting direction (ascending or descending)
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end
end
