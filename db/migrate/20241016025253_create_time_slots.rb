# frozen_string_literal: true

class CreateTimeSlots < ActiveRecord::Migration[7.2]
  def change
    create_table :time_slots do |t|
      t.string :day
      t.string :start_time
      t.string :end_time
      t.string :slot_type

      t.timestamps
    end
  end
end
