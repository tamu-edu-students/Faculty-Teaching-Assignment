# frozen_string_literal: true

class DropSections < ActiveRecord::Migration[7.2]
  def change
    remove_foreign_key :room_bookings, :sections if foreign_key_exists?(:room_bookings, :sections)

    remove_index :room_bookings, :section_id if index_exists?(:room_bookings, :section_id)

    remove_column :room_bookings, :section_id, :integer if column_exists?(:room_bookings, :section_id)

    # Get rid of sections
    return unless table_exists?(:sections)

    drop_table :sections do |t|
      t.references :course, foreign_key: true
      t.timestamps
    end
  end
end
