class AddScheduleReferenceToRooms < ActiveRecord::Migration[7.2]
  def change
    add_reference :rooms, :schedule, null: false, foreign_key: true
  end
end
