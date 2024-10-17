# frozen_string_literal: true

# app/controllers/csv_controller.rb
class CsvController < ApplicationController
  require 'csv'

  def upload
    if csv_file_present?
      process_csv_file
    else
      flash[:error] = 'Please upload a CSV file.'
    end
    redirect_to user_path(@current_user)
  end

  private

  def csv_file_present?
    params[:csv_file].present?
  end

  def process_csv_file
    file = params[:csv_file].path
    parse_and_handle_csv(file)
  end

  def parse_and_handle_csv(file)
    parse_csv(file)
    flash[:notice] = 'CSV file uploaded successfully.'
  rescue CSV::MalformedCSVError => e
    flash[:error] = "Cannot parse CSV file: #{e.message}"
  end

  def parse_csv(file)
    csv = CSV.read(file, headers: true)
    Rails.logger.debug { "CSV Headers: #{csv.headers}" }
    csv.each do |row|
      Rails.logger.debug row.to_hash
    end
  end
end
