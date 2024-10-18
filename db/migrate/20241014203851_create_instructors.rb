class CreateInstructors < ActiveRecord::Migration[6.1]
  def change
    create_table :instructors, id: false do |t|
      t.primary_key :person_uid  # Set person_uid as the primary key
      t.integer :id_number
      t.string :last_name
      t.string :first_name
      t.string :middle_name
      t.string :email
      t.boolean :before_9
      t.boolean :after_3
      t.text :beaware_of

      t.timestamps
    end
  end
end
