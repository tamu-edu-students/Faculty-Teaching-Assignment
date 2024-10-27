FactoryBot.define do
  factory :room_booking do
    room { nil }
    time_slot { nil }
    is_available { false }
    is_lab { false }
  end
end
