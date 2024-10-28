# frozen_string_literal: true

class CreateInstructorPreferences < ActiveRecord::Migration[7.2]
  def change
    create_table :instructor_preferences do |t|
      t.references :instructor, null: false, foreign_key: true
      t.string :course
      t.integer :preference_level

      t.timestamps
    end
  end
end
