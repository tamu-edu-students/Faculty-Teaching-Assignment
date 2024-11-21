# frozen_string_literal: true

class AddSectionNumbersToCourses < ActiveRecord::Migration[7.2]
  def change
    add_column :courses, :section_numbers, :string
  end
end
