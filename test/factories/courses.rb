FactoryBot.define do
  factory :course do
    course_number { 1 }
    title { "MyString" }
    description { "MyString" }
    subject { "MyString" }
    credits { 1 }
    has_lab { false }
  end
end
