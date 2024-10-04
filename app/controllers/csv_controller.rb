# app/controllers/csv_controller.rb
class CsvController < ApplicationController
  require 'csv'

  def upload
    if params[:csv_file].present?
      file = params[:csv_file].path
      parse_csv(file)
      flash[:notice] = "CSV file uploaded successfully."
      # Rails.logger.debug "Flash notice set: #{flash[:notice]}"
      # flash.keep(:notice)  # Keep the flash across multiple redirects
      redirect_to user_path(@current_user)
    else
      flash[:error] = "Please upload a CSV file."
      # Rails.logger.debug "Flash error set: #{flash[:error]}"
      # flash.keep(:error)  # Keep the flash across multiple redirects
      redirect_to user_path(@current_user)
    end
  end

  private

  def parse_csv(file)
    csv = CSV.read(file, headers: true)
    Rails.logger.debug "CSV Headers: #{csv.headers}"
    csv.each do |row|
      Rails.logger.debug row.to_hash
      break
    end
  end
end