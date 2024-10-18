class Instructor < ApplicationRecord
    belongs_to :schedule
    self.primary_key = 'person_uid'
end