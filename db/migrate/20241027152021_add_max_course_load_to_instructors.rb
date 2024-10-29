# frozen_string_literal: true

# Migration for adding a column to Instructor Preferences
class AddMaxCourseLoadToInstructors < ActiveRecord::Migration[7.2]
  def change
    add_column :instructors, :max_course_load, :integer
  end
end
