class CreateTeachingPlans < ActiveRecord::Migration[6.1]
  def change
    create_table :teaching_plans do |t|  
      t.references :schedule, null: false, foreign_key: true  # Create foreign key directly
      t.references :course, null: false, foreign_key: true    # Create foreign key directly
      t.integer :num_sections
      t.integer :num_students

      t.timestamps
    end
  end
end
