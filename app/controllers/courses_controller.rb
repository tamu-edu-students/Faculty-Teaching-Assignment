# frozen_string_literal: true

# Courses Controller
class CoursesController < ApplicationController
  helper_method :sort_column, :sort_direction
  before_action :set_schedule, only: [:index]
  def index
    @schedule = current_user.schedules.find(params[:schedule_id])
    @show_hidden = false
    @show_hidden = true if params[:show_hidden] == 'true'
    @courses  = @schedule.courses.where(hide: @show_hidden).includes(:sections).all
    direction = params[:direction] == 'desc' ? 'desc' : 'asc'
    @courses = @courses.order("#{sort_column} #{direction}")
  end

  def toggle_hide
    set_schedule
    course = Course.find(params[:id])

    redirect_to_schedule_with_alert and return if hiding_course_disallowed?(course)

    if update_course_hide(course)
      redirect_to_schedule_with_notice
    else
      render_update_error(course)
    end
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
    @schedule = current_user.schedules.find(params[:schedule_id]) if params[:schedule_id]
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = 'Schedule not found.'
    redirect_to schedules_path
  end

  def hiding_course_disallowed?(course)
    course.hide == false && course_has_room_bookings?(course)
  end

  def course_has_room_bookings?(course)
    RoomBooking.joins(:section).where(sections: { course_id: course.id }).exists?
  end

  def redirect_to_schedule_with_alert
    flash[:alert] = 'Cannot hide course because it has associated room bookings.'
    redirect_to "/schedules/#{@schedule.id}/courses"
  end

  def update_course_hide(course)
    course.update(hide: !course.hide)
  end

  def redirect_to_schedule_with_notice
    redirect_to "/schedules/#{@schedule.id}/courses", notice: 'Course updated successfully.'
  end

  def render_update_error(course)
    render json: { error: 'Failed to update course hide status', details: course.errors.full_messages }, status: :unprocessable_entity
  end
end
