# frozen_string_literal: true

class AddScheduleReferenceToRooms < ActiveRecord::Migration[7.2]
  def change
    add_reference :rooms, :schedule, default: -1, null: false, foreign_key: true
  end
end
