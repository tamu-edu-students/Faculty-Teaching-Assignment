class ChangeInstructorsPrimaryKey < ActiveRecord::Migration[6.1]
  def change
    # This will drop the existing instructors table
    drop_table :instructors if table_exists?(:instructors)

    # Recreate the instructors table with the default primary key
    create_table :instructors do |t|
      t.integer :id_number
      t.string :last_name
      t.string :first_name
      t.string :middle_name
      t.string :email
      t.boolean :before_9
      t.boolean :after_3
      t.text :beaware_of
      t.references :schedule, foreign_key: true
      
      t.timestamps
    end
  end
end
