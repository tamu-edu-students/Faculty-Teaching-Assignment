# frozen_string_literal: true

# Courses Controller
class CoursesController < ApplicationController
  helper_method :sort_column, :sort_direction
  before_action :set_schedule, only: [:index]
  def index
    @schedule = Schedule.find(params[:schedule_id])
    @courses  = @schedule.courses.includes(:sections).all
    direction = params[:direction] == 'desc' ? 'desc' : 'asc'
    @courses = @courses.order("#{sort_column} #{direction}")
  end

  def fetch_courses
    room_id = params[:room_id]
    time_slot_id = params[:time_slot_id]

    @schedule = Schedule.find(params[:schedule_id])
    @courses = @schedule.courses
    @sections = Section.joins(:course)

    render json: { html: render_to_string(partial: "/shared/courses_list", locals: { sections: @sections }) }
  end

  private

  # Define the allowed sorting columns
  def sort_column
    Course.column_names.include?(params[:sort]) ? params[:sort] : 'course_number'
  end

  # Define the sorting direction (ascending or descending)
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end

  # Set the schedule correctly
  def set_schedule
    @schedule = Schedule.find(params[:schedule_id]) if params[:schedule_id]
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = 'Schedule not found.'
    redirect_to schedules_path
  end
end
