# app/controllers/schedules_controller.rb
class SchedulesController < ApplicationController
    def index
        @user = current_user    
        @schedules = Schedule.all
    end
    
    def show
        @user = current_user
        @schedule = Schedule.find(params[:id])
    end
  end
  