class Course < ApplicationRecord
    belongs_to :schedule
    validates :course_number, presence: true
    validates :subject, presence: true#, default: 'CSCE'
    # validates :has_lab, inclusion: { in: [true, false] }
    
    after_initialize :set_defaults
  
    private
  
    def set_defaults
      self.subject ||= 'CSCE'
    #   self.has_lab ||= false
    end
    def course_params
        params.require(:course).permit(:course_number, :title, :description, :subject, :lec_hours, :lab_hours, :schedule_id)
    end
  end
  