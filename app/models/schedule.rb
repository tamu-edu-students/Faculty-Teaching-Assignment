class Schedule < ApplicationRecord
    validates :schedule_name, :semester_name, presence: true
end
