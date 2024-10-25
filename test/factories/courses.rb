# frozen_string_literal: true

FactoryBot.define do
  factory :course do
    course_number { 'MyString' }
    max_seats { 1 }
    lecture_type { 'MyString' }
    num_labs { 1 }
    schedule { nil }
  end
end
