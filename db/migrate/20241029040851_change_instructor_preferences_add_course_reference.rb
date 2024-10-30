# frozen_string_literal: true

# Add the foreign key to courses in instructor_preferences and remove the string column
class ChangeInstructorPreferencesAddCourseReference < ActiveRecord::Migration[7.2]
  def change
    remove_column :instructor_preferences, :course, :string
    add_reference :instructor_preferences, :course, null: false, foreign_key: true
  end
end
