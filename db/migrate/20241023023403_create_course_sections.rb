class CreateCourseSections < ActiveRecord::Migration[6.1]
  def change
    create_table :course_sections do |t|
      t.integer :section_number
      t.integer :size

      t.references :course, null: false, foreign_key: true  # Adds course_number as a reference
      t.references :room, foreign_key: true                   # Adds room_booking_id as a reference
      t.references :schedule, foreign_key: true               # Adds schedule_id as a reference

      t.timestamps
    end
  end
end
