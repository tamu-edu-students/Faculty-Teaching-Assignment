class CoursesController < ApplicationController
  def index
    @schedule = Schedule.find(params[:schedule_id])
    @courses = Course.all.order(:course_number)
    
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
