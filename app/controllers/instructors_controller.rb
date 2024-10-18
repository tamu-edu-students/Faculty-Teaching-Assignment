class InstructorsController < ApplicationController

 def index
    @schedule = Schedule.find(params[:schedule_id])
    @instructors = @schedule.instructors
 end

end
