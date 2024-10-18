class InstructorsController < ApplicationController
    def index
      @instructors = Instructor.all # Fetch all instructors
    end
  
    def show
      @instructor = Instructor.find(params[:id]) # Fetch instructor by ID
    end
end
  