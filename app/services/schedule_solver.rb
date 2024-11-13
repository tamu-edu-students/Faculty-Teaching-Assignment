# frozen_string_literal: true

require 'rulp'
require 'hungarian_algorithm'

class ScheduleSolver
  def self.solve(classes, rooms, times, instructors, locks)
    num_classes = classes.length
    num_rooms = rooms.length
    num_times = times.length
    num_instructors = instructors.length

    # Sanity check: contracted teaching classes >= offered classes
    raise StandardError, 'Not enough teaching hours for given class offerings!' if num_instructors < num_classes

    # Allocate ijk binary decision variables
    sched_flat = Array.new(num_classes * num_rooms * num_times, &X_b)

    # Reshape into a 3D tensor
    # i.e. sched[i][j][k] = 1 is class i is located at room j for time k
    sched = sched_flat.each_slice(num_times).each_slice(num_rooms).to_a

    # Create objective function
    # Minimize the number of empty seats in a full section
    puts 'Creating objective function'
    objective = sched.map.with_index do |mat, c|
      mat.map.with_index do |row, r|
        row.map.with_index do |val, _t|
          val * (rooms[r]['capacity'] - classes[c]['max_seats'])
        end.reduce(:+)
      end.reduce(:+)
    end.reduce(:+)

    # Constraint #1: Room capacity >= class enrollment
    puts 'Generating capacity constraints'
    cap_constraints =
      (0...num_classes).map do |c|
        (0...num_rooms).map do |r|
          (0...num_times).map do |t|
            sched[c][r][t] * (rooms[r]['capacity'] - classes[c]['max_seats']) >= 0
          end
        end
      end

    # Constraint #2: No two classes can share one room at the same time
    # For some reason, the constraints can't be generated using map
    # Create the array at the beginning, and append individually
    puts 'Generating share constraints'
    share_constraints = []
    (0...num_rooms).each do |r|
      (0...num_times).each do |t|
        share_constraints.append((0...num_classes).map { |c| sched[c][r][t] }.reduce(:+) <= 1)
      end
    end

    # Constraint #3: Every class has exactly one assigned room and time
    # Need the guaranteed zero to enforce the LHS is 1
    # See Constraint #4 for why
    puts 'Generating place constraints'
    place_constraints =
      (0...num_classes).map do |c|
        sched[c].flatten.reduce(:+) + GuaranteedZero_b == 1
      end

    # Hash room_id to (0...num_rooms)
    # Allows us to map rooms => array indices
    room_id_hash = (0...num_rooms).map{|r| [rooms[r]['id'], r]}.to_h
    class_id_hash = (0...num_classes).map{|c| [classes[c]['id'], c]}.to_h
    time_id_hash = (0...num_times).map{|t| [times[t][3], t]}.to_h
    
    # Constraint #4: Respect locked courses
    # locks[i] = (class, room, time) triplet
    puts 'Generating lock constraints'
    lock_constraints = []
    locks.each do |class_id, room_id, time_id|
      # For unknown reasons, I can't write sched[c][r][t] == 1
      # Ruby will evaluate this as a boolean expression, instead of giving the constraint
      # Introduce a dummy variable that is guaranteed to be zero
      # If their sum is one  => sched[c][r][t] must be 1
      lock_constraints.append(sched[class_id_hash[class_id]][room_id_hash[room_id]][time_id_hash[time_id]] + GuaranteedZero_b == 1)
    end

    # Constraint #5: Courses that require special designations get rooms that meet them
    puts 'Generating designation constraints'
    designation_constraints = []
    (0...num_classes).each do |c|
      (0...num_rooms).each do |r|
        next if classes[c]['is_lab'] == rooms[r]['is_lab']
        (0...num_times).each do |t|
          designation_constraints.append(sched[c][r][t] + GuaranteedZero_b == 0)
        end
      end
    end

    # Constraint #6: Ensure rooms are not scheduled at overlapping times
    # Go through all pairs of time slots and find those that overlap
    puts 'Generating overlapping constraints'
    overlapping_pairs = []
    (0...num_times).each do |t1|
      (t1 + 1...num_times).each do |t2|
        overlapping_pairs.append([t1, t2]) if overlaps?(times[t1], times[t2])
      end
    end

    # For each pair of overlapping times, ensure that at most one is used
    overlap_constraints = []
    (0...num_rooms).each do |r|
      overlapping_pairs.each do |t1, t2|
        overlap_constraints.append((0...num_classes).map { |c| sched[c][r][t1] + sched[c][r][t2] }.reduce(:+) <= 1)
      end
    end

    # Ensure GuaranteedZero is, in fact, zero
    zero_constraint = [GuaranteedZero_b <= 0]

    # Consolidate constraints
    constraints = cap_constraints + share_constraints + place_constraints + lock_constraints + overlap_constraints + designation_constraints + zero_constraint

    # Form ILP and solve
    problem = Rulp::Min(objective)
    problem[constraints]
    # Silence RULP output, unless there's an error
    Rulp::log_level = Logger::ERROR

    begin
      status = Rulp::Glpk(problem)
    rescue StandardError
      raise StandardError, 'Solution infeasible!'
    end

    # Now that the courses have been assigned rooms and times, we now add instructors
    # This can be viewed as a bipartite matching (see ILP doc)
    unhappiness_matrix = Array.new(num_instructors) { Array.new(num_classes) { 0 } }
    morning_haters = instructors.reject { |i| i['before_9'] }
    evening_haters = instructors.reject { |i| i['after_3'] }

    # Map professor name in database to (0...num_instructors) so we can use them as array indices
    hash = {}
    (0...num_instructors).each do |i|
      hash[instructors[i]] = i
    end

    morning_classes = []
    evening_classes = []
    (0...num_classes).each do |c|
      (0...num_rooms).each do |r|
        (0...num_times).each do |t|
          next unless sched[c][r][t].value

          if before_9?(times[t])
            morning_classes.append(c)
          elsif after_3?(times[t])
            evening_classes.append(c)
          end
        end
      end
    end

    # Fill in unhappiness matrix
    morning_haters.each do |p|
      morning_classes.each do |c|
        unhappiness_matrix[hash[p]][c] = 1
      end
    end

    evening_haters.each do |p|
      evening_classes.each do |c|
        unhappiness_matrix[hash[p]][c] = 1
      end
    end

    # Solve the min weight perfect matching via the Hungarian algorithm
    # While extensions to nonperfect matchings exist for HA, this particular library doesn't support them
    # The library modifies the matrix, so create a deep copy first
    copy = unhappiness_matrix.map(&:dup)
    matching = HungarianAlgorithm.new(unhappiness_matrix).process.sort

    # matching is a 2D array, where each element [i,j] represents the assignment of professsor i to class j
    # Flatten this to a simpler map of profs to classes
    # i.e have matching[i] = j instead of matching[i] = [i,j]
    matching = matching.map { |_u, v| v }

    total_unhappiness = 0
    (0...num_classes).each do |c|
      assigned_prof = instructors[matching.index(c)]
      (0...num_rooms).each do |r|
        (0...num_times).each do |t|
          next unless sched[c][r][t].value

          unhappiness = copy[hash[assigned_prof]][c]
          total_unhappiness += unhappiness

          RoomBooking.create(
            room_id: rooms[r]['id'],
            time_slot_id: times[t][3],
            is_available: true,
            is_lab: false,
            created_at: Time.now,
            updated_at: Time.now,
            section_id: Section.find_by(course_id: classes[c]['id']).id,
            instructor_id: assigned_prof['id']
          )

        end
      end
    end

    total_unhappiness
  end

  # Find if two timeslots overlap
  # time1 = [days, start_time, end_time]
  def self.overlaps?(time1, time2)
    days1 = time1[0]
    days2 = time2[0]
    return false unless day_overlaps?(days1, days2)

    start1 = Time.parse(time1[1])
    start2 = Time.parse(time2[1])
    end1 = Time.parse(time1[2])
    end2 = Time.parse(time2[2])
    (start1 <= start2 && start2 <= end1) || (start2 <= start1 && start1 <= end2)
  end

  # Check if two times overlap on at least one day
  def self.day_overlaps?(days1, days2)
    d1 = days1.scan(/M|T|W|R|F/)
    d2 = days2.scan(/M|T|W|R|F/)
    !(d1 & d2).empty?
  end

  def self.before_9?(time)
    start_time = time[1]
    Time.parse(start_time) <= Time.parse('9:00')
  end

  def self.after_3?(time)
    end_time = time[2]
    Time.parse(end_time) >= Time.parse('15:00')
  end
end
