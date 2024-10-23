class Course < ApplicationRecord
    has_many :teaching_plans
    has_many :sections  
  end
  