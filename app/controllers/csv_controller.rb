# frozen_string_literal: true

# app/controllers/csv_controller.rb
class CsvController < ApplicationController
  require 'csv'

  def upload
    if params[:csv_file].present?
      file = params[:csv_file].path
      parse_csv file
      flash[:notice] = 'File uploaded successfully'
    else
      flash[:error] = 'Please upload a CSV file.'
    end
  end

  private
  def parse_csv(file)
    begin
      csv = CSV.read(file, headers: true)
      Rails.logger.debug { "CSV Headers: #{csv.headers}" }
      csv.each do |row|
        Rails.logger.debug row.to_hash
      end
    rescue CSV::MalformedCSVError => e
      flash[:error] = "There is a problem with the CSV file: #{e.message}"
    rescue CSV::InvalidEncodingError => e
      flash[:error] = "There is a problem with the CSV file: #{e.message}"
    end


  end
end
