class DropSections < ActiveRecord::Migration[7.2]
  def change
    if foreign_key_exists?(:room_bookings, :sections)
      remove_foreign_key :room_bookings, :sections
    end

    if index_exists?(:room_bookings, :section_id)
      remove_index :room_bookings, :section_id
    end

    if column_exists?(:room_bookings, :section_id)
      remove_column :room_bookings, :section_id, :integer
    end

    # Get rid of sections
    if table_exists?(:sections)
      drop_table :sections do |t|
        t.references :course, foreign_key: true
        t.timestamps
      end
    end
  end
  
end
