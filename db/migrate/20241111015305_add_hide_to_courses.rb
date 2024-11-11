# frozen_string_literal: true

class AddHideToCourses < ActiveRecord::Migration[7.2]
  def change
    add_column :courses, :hide, :boolean, default: false, null: false
  end
end
