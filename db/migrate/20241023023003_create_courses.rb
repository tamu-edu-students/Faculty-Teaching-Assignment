class CreateCourses < ActiveRecord::Migration[6.1]
  def change
    create_table :courses do |t|
      t.integer :course_number
      t.string :title
      t.text :description
      t.string :subject
      t.integer :credits
      t.boolean :has_lab

      t.timestamps
    end
  end
end
