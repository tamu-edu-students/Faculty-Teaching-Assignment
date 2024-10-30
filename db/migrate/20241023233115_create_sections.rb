# frozen_string_literal: true

# Crete the sectons table
class CreateSections < ActiveRecord::Migration[7.2]
  def change
    create_table :sections do |t|
      t.string :section_number
      t.integer :seats_alloted
      t.references :course, null: false, foreign_key: true

      t.timestamps
    end
  end
end
