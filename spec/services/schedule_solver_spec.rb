# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ScheduleSolver do
  let(:small_room) { { 'capacity' => 30, 'id' => 1 } }
  let(:large_room) { { 'capacity' => 100, 'id' => 2 } }
  let(:lab_room) { { 'capacity' => 100, 'is_lab' => true, 'id' => 3 } }

  let(:small_course) { { 'max_seats' => 20, 'id' => 1 } }
  let(:large_course) { { 'max_seats' => 80, 'id' => 2 } }

  let(:morning_hater) { { 'before_9' => false, 'after_3' => true, 'id' => 1, 'max_course_load' => 1 } }
  let(:evening_hater) { { 'before_9' => true, 'after_3' => false, 'id' => 2, 'max_course_load' => 2 } }
  let(:amicable) { { 'before_9' => true, 'after_3' => true, 'id' => 3, 'max_course_load' => 3 } }

  let(:morning) { ['MWF', '08:00', '8:50', 1] }
  let(:afternoon) { ['MWF', '13:50', '14:40', 2] }
  let(:evening) { ['TR', '15:50', '17:10', 3] }
  let(:friday_lab) { ['F', '08:30', '10:30', 4] }

  describe 'test error conditions' do
    context 'when there are not enough teaching hours' do
      it 'raises an error due to insufficient manpower' do
        expect do
          ScheduleSolver.solve([large_course, small_course],
                               [small_room, large_room],
                               [evening],
                               [morning_hater],
                               [])
        end.to raise_error(StandardError, 'Not enough teaching hours (1) for given class offerings (2)!')
      end
    end

    context 'when room capacities are too small for courses' do
      it 'raises an error due to insufficient room capacities' do
        expect do
          ScheduleSolver.solve([large_course],
                               [small_room],
                               [morning],
                               [amicable],
                               [])
        end.to raise_error(StandardError, 'Solution infeasible!')
      end
    end

    context 'when no lecture rooms are available' do
      it 'raises an error due to insufficient room modality' do
        expect do
          ScheduleSolver.solve([small_course],
                               [lab_room],
                               [morning],
                               [amicable],
                               [])
        end.to raise_error(StandardError, 'Solution infeasible!')
      end
    end

    # NOTE: See commentary in schedule_solver.rb for overlap functionality
    # context 'when timeslots conflict' do
    #   it 'raises an error due to conflicting times' do
    #     expect do
    #       ScheduleSolver.solve([small_course, large_course],
    #                            [large_room],
    #                            [morning, friday_lab],
    #                            [amicable, evening_hater],
    #                            [])
    #     end.to raise_error(StandardError, 'Solution infeasible!')
    #   end
    # end

    context 'when a morning hater is assigned to a morning class' do
      it 'returns a schedule, with a warning about relaxed constraints' do
        result, relax = ScheduleSolver.solve([small_course],
                                             [large_room],
                                             [morning],
                                             [morning_hater],
                                             [])
        expect(result.nil?).to be false
        expect(relax).to be true
      end
    end

    context 'when a evening hater is assigned to a evening class' do
      it 'returns a schedule, with a warning about relaxed constraints' do
        result, relax = ScheduleSolver.solve([small_course],
                                             [large_room],
                                             [evening],
                                             [evening_hater],
                                             [])
        expect(result.nil?).to be false
        expect(relax).to be true
      end
    end

    context 'when a professor is forced to be in two places at once' do
      it 'return an error' do
        expect do
          ScheduleSolver.solve([small_course, large_course],
                               [small_room, large_room],
                               [morning],
                               [amicable],
                               [])
        end.to raise_error(StandardError, 'Solution infeasible!')
      end
    end
  end

  describe 'algorithm finds a schedule' do
    context 'there exists a feasible schedule' do
      it 'finds a schedule' do
        result = ScheduleSolver.solve([small_course, large_course],
                                      [small_room, large_room],
                                      [morning, evening],
                                      [morning_hater, evening_hater],
                                      [])
        expect(result.nil?).to be false
      end
    end

    context 'professors teach multiple courses' do
      it 'finds a schedule' do
        result = ScheduleSolver.solve([small_course, large_course],
                                      [large_room],
                                      [morning, evening, friday_lab],
                                      [amicable],
                                      [])
        expect(result.nil?).to be false
      end
    end
  end
end
