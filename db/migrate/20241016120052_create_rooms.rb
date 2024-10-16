class CreateRooms < ActiveRecord::Migration[7.2]
  def change
    create_table :rooms do |t|
      t.integer :campus
      t.boolean :is_lecture_hall
      t.boolean :is_learning_studio
      t.boolean :is_lab
      t.string :building_code
      t.string :room_number
      t.integer :capacity
      t.boolean :is_active
      t.string :comments

      t.timestamps
    end
  end
end
