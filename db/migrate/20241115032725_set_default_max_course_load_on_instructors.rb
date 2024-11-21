# frozen_string_literal: true

class SetDefaultMaxCourseLoadOnInstructors < ActiveRecord::Migration[7.2]
  def change
    change_column_default :instructors, :max_course_load, 1
  end
end
