# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ScheduleSolver, type: :model do
  fixtures :schedules, :rooms, :courses, :instructors
  let(:morning) {["MWF","08:00","8:50",1]}
  let(:afternoon) {["MWF","13:50","14:40",2]}
  let(:evening) {["TR","15:50","17:10",3]}
  let(:friday_lab) {["F","08:30","10:30",4]}

  describe 'test error conditions' do
    context 'when there are not enough professors' do
      it 'raises an error due to insufficient instructors' do
        expect do
          ScheduleSolver.solve([courses(:large_course), courses(:small_course)],
                               [rooms(:small_room, :large_room)],
                               [morning],
                               [instructors(:amicable)],
                               [])
        end.to raise_error(StandardError, 'Not enough teaching hours for given class offerings!')
      end
    end

    context 'when room capacities are too small for courses' do
      it 'raises an error due to insufficient room capacities' do
        expect do
          ScheduleSolver.solve([courses(:large_course)],
                               [rooms(:small_room)],
                               [morning],
                               [instructors(:amicable)],
                               [])
        end.to raise_error(StandardError, 'Solution infeasible!')
      end
    end

    context 'when no lecture rooms are available' do
      it 'raises an error due to insufficient room modality' do
        expect do
          ScheduleSolver.solve([courses(:small_course)],
                               [rooms(:lab_room)],
                               [morning],
                               [instructors(:amicable)],
                               [])
        end.to raise_error(StandardError, 'Solution infeasible!')
      end
    end

    context 'when timeslots conflict' do
      it 'raises an error due to conflicting times' do
        expect do
          ScheduleSolver.solve([courses(:small_course), courses(:medium_course)],
                               [rooms(:large_room)],
                               [morning, friday_lab],
                               [instructors(:amicable), instructors(:evening_hater)],
                               [])
        end.to raise_error(StandardError, 'Solution infeasible!')
      end
    end

    context 'when a morning hater is assigned to a morning class' do
      it 'returns a nonzero unhappiness' do
        unhappiness = ScheduleSolver.solve([courses(:small_course)],
                               [rooms(:large_room)],
                               [morning],
                               [instructors(:morning_hater)],
                               [])
        expect(unhappiness).to be > 0
      end
    end

    context 'when a evening hater is assigned to a evening class' do
      it 'returns a nonzero unhappiness' do
        unhappiness = ScheduleSolver.solve([courses(:small_course)],
                               [rooms(:large_room)],
                               [evening],
                               [instructors(:evening_hater)],
                               [])
        expect(unhappiness).to be > 0
      end
    end
  end

  describe 'algorithm finds a schedule' do
    context 'there exists a feasible schedule' do
      it 'finds a schedule' do
        result = ScheduleSolver.solve([courses(:small_course), courses(:medium_course)],
                                      [rooms(:small_room), rooms(:medium_room), rooms(:large_room)],
                                      [morning, evening],
                                      [instructors(:morning_hater), instructors(:evening_hater)],
                                      [])
        expect(result.nil?).to be false
      end
    end
  end
end
