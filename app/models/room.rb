class Room < ApplicationRecord
    enum campus: { NONE: 0, CS: 1, GV: 2 }

    validates :building_code, presence: true
    validates :room_number, presence: true
    validates :capacity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    validates :is_lecture_hall, :is_learning_studio, :is_lab, inclusion: { in: [true, false] }
end
  