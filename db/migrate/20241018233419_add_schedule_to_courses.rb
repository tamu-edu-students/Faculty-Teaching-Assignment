class AddScheduleToCourses < ActiveRecord::Migration[7.2]
  def change
    add_reference :courses, :schedule, null: false, foreign_key: true
  end
end
