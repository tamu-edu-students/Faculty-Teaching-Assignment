class AddUserRefToSchedules < ActiveRecord::Migration[7.2]
  def change
    add_reference :schedules, :user, null: false, foreign_key: true
  end
end
