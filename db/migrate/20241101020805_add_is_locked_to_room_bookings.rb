class AddIsLockedToRoomBookings < ActiveRecord::Migration[7.2]
  def change
    add_column :room_bookings, :is_locked, :boolean
  end
end
