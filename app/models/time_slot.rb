class CreateTimeSlots < ActiveRecord::Migration[6.1]
    def change
      create_table :time_slots do |t|
        t.string :day
        t.string :start_time
        t.string :end_time
        t.string :slot_type # Either 'LEC' or 'LAB'
  
        t.timestamps
      end
    end
  end
  