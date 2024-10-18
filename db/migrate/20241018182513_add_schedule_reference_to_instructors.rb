# frozen_string_literal: true

# Schedule migration
class AddScheduleReferenceToInstructors < ActiveRecord::Migration[7.2]
  def change
    add_reference :instructors, :schedule, null: false, foreign_key: true
  end
end
