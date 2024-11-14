# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Schedule, type: :model do
  before(:all) do
    @schedule1 = create(:schedule)
  end

  it 'is valid with valid attributes' do
    expect(@schedule1).to be_valid
  end

  it 'is not valid without a schedule name' do
    schedule2 = build(:schedule, schedule_name: nil)
    expect(schedule2).to_not be_valid
  end

  it 'is not valid without a semester name' do
    schedule2 = build(:schedule, semester_name: nil)
    expect(schedule2).to_not be_valid
  end

  it 'is invalid without a user' do
    @schedule1.user = nil
    expect(@schedule1).to_not be_valid
    expect(@schedule1.errors[:user]).to include('must exist')
  end
end
