# app/controllers/csv_controller.rb
class CsvController < ApplicationController
  require 'csv'

  skip_before_action :require_login

  def upload
    if params[:csv_file].present?
      file = params[:csv_file].path
      parse_csv(file)
    else
      flash[:error] = "Please upload a CSV file."
      redirect_to root_path
    end
  end

  private

  def parse_csv(file)
    csv = CSV.read(file, headers: true)
    puts "CSV Headers: #{csv.headers}"
    csv.each do |row|
      puts row.to_hash
    end
  end
end