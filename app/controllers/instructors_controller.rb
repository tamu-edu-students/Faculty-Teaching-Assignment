class InstructorsController < ApplicationController

   before_action :set_schedule, only: [:index]
   def index
    @schedule = Schedule.find(params[:schedule_id])
    @instructors = @schedule.instructors
   end
   
   private
   def set_schedule
      @schedule = Schedule.find(params[:schedule_id]) if params[:schedule_id]
    rescue ActiveRecord::RecordNotFound
      flash[:alert] = 'Schedule not found.'
      redirect_to schedules_path
    end
end
