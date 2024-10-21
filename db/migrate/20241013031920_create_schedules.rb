# frozen_string_literal: true

# Schedules migration
class CreateSchedules < ActiveRecord::Migration[7.2]
  def change
    create_table :schedules do |t|
      t.string :schedule_name
      t.string :semester_name

      t.timestamps
    end
  end
end
