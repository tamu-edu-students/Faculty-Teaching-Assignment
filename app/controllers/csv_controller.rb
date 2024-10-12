# frozen_string_literal: true

# app/controllers/csv_controller.rb
class CsvController < ApplicationController
  require 'csv'

  def upload
    if params[:csv_file].present?
      file = params[:csv_file].path
      begin
        parse_csv(file)
        flash[:notice] = 'CSV file uploaded successfully.'
      rescue CSV::MalformedCSVError => e
        flash[:error] = "Cannot parse CSV file: #{e.message}"
      end
    else
      flash[:error] = 'Please upload a CSV file.'
    end
    redirect_to user_path(@current_user)
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
