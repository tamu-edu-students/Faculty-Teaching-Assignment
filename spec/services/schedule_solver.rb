# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ScheduleSolver, type: :model do
  fixtures 'schedules', 'rooms', 'courses', 'time_slots', 'instructors'

  describe 'test error conditions' do
    context 'when there are not enough professors' do
      it 'raises an error due to insufficient instructors' do
        expect do
          ScheduleSolver.solve([courses(:large_course), courses(:small_course)],
                               [rooms(:small_room, :large_room)],
                               [time_slots(:morning)],
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
                               [time_slots(:morning)],
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
                               [time_slots(:morning)],
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
                               [time_slots(:morning), time_slots(:friday_lab)],
                               [instructors(:amicable), instructors(:evening_hater)],
                               [])
        end.to raise_error(StandardError, 'Solution infeasible!')
      end
    end

    context 'when a morning hater is assigned to a morning class' do
      it 'raises an error due to instructor preference' do
        expect do
          ScheduleSolver.solve([courses(:small_course)],
                               [rooms(:large_room)],
                               [time_slots(:morning)],
                               [instructors(:morning_hater)],
                               [])
        end.to raise_error(StandardError, 'Solution infeasible!')
      end
    end

    context 'when a evening hater is assigned to a evening class' do
      it 'raises an error due to instructor preference' do
        expect do
          ScheduleSolver.solve([courses(:small_course)],
                               [rooms(:large_room)],
                               [time_slots(:evening)],
                               [instructors(:evening_hater)],
                               [])
        end.to raise_error(StandardError, 'Solution infeasible!')
      end
    end
  end

  describe 'algorithm finds a schedule' do
    context 'there exists a feasible schedule' do
      it 'finds a schedule' do
        result = ScheduleSolver.solve([courses(:small_course), courses(:medium_course)],
                                      [rooms(:small_room), rooms(:medium_room), rooms(:large_room)],
                                      [time_slots(:morning), time_slots(:evening)],
                                      [instructors(:morning_hater), instructors(:evening_hater)],
                                      [])
        expect(result.nil?).to be false
      end
    end
  end
end
