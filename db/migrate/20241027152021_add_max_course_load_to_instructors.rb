# frozen_string_literal: true

class AddMaxCourseLoadToInstructors < ActiveRecord::Migration[7.2]
  def change
    add_column :instructors, :max_course_load, :integer
  end
end
