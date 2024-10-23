class TeachingPlan < ApplicationRecord
    belongs_to :course
    belongs_to :schedule  
  end
  