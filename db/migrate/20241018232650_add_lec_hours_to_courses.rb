class AddLecHoursToCourses < ActiveRecord::Migration[7.2]
  def change
    add_column :courses, :lec_hours, :integer
    add_column :courses, :lab_hours, :integer
  end
end
