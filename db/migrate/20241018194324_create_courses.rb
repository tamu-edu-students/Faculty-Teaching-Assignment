class CreateCourses < ActiveRecord::Migration[7.2]
  def change
    create_table :courses do |t|
      t.integer :course_number
      t.string :title
      t.string :description
      t.string :subject
      t.integer :lec_hours
      t.integer :lab_hours
      
      t.timestamps
    end
  end
end
