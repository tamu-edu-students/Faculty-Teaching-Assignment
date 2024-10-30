class CreateRoomBlocks < ActiveRecord::Migration[6.1]
  def change
    create_table :room_blocks do |t|
      t.references :room, null: false, foreign_key: true
      t.references :time_slot, null: false, foreign_key: true
      t.boolean :is_blocked, default: true

      t.timestamps
    end
  end
end
