# frozen_string_literal: true

class CreateRoomBookings < ActiveRecord::Migration[7.2]
  def change
    create_table :room_bookings do |t|
      t.references :room, null: false, foreign_key: true
      t.references :time_slot, null: false, foreign_key: true
      t.boolean :is_available
      t.boolean :is_lab

      t.timestamps
    end
  end
end
