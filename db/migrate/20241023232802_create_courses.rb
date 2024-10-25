# frozen_string_literal: true

class CreateCourses < ActiveRecord::Migration[7.2]
  def change
    create_table :courses do |t|
      t.string :course_number
      t.integer :max_seats
      t.string :lecture_type
      t.integer :num_labs
      t.references :schedule, null: false, foreign_key: true

      t.timestamps
    end
  end
end
