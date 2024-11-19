# frozen_string_literal: true

require 'rulp'
require 'hungarian_algorithm'
require 'algorithms'

class ScheduleSolver
  def self.solve(classes, rooms, times, instructors, locks)
    num_classes = classes.length
    num_rooms = rooms.length
    num_times = times.length
    num_instructors = instructors.length

    # Get the total number of contracted hours and ensure it's at least the number offered classes 
    hours = instructors.map{ |i| i['max_course_load']}
    total_course_velocity = hours.sum 
    if total_course_velocity < num_classes
      raise StandardError, "Not enough teaching hours (#{total_course_velocity}) for given class offerings (#{num_classes})!"
    elsif total_course_velocity > num_classes 
      # Two options: add more classes or assign professors fewer classes than their contract specifies
      # We choose the latter and reduce professors' hours in a greedy fashion
      hours = reduce_hours(hours, total_course_velocity - num_classes)
    end

    # Initialize schedule tensor
    # i.e. sched[i][j][k] = 1 is class i is located at room j for time k    
    sched = init_ilp_tensor(num_classes, num_rooms, num_times)

    # Create objective function
    # Minimize the number of empty seats in a full section
    puts 'Creating objective function'
    objective = 
      (0...num_classes).map do |c|
        (0...num_rooms).map do |r|
          (0...num_times).map do |t|
            sched[c][r][t] * (rooms[r]['capacity'] - classes[c]['max_seats'])
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
    room_id_hash = (0...num_rooms).map { |r| [rooms[r]['id'], r] }.to_h
    class_id_hash = (0...num_classes).map { |c| [classes[c]['id'], c] }.to_h
    time_id_hash = (0...num_times).map { |t| [times[t][3], t] }.to_h

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
    overlap_map = Hash.new { |hash, key| hash[key] = Set.new }
    (0...num_times).each do |t1|
      (t1 + 1...num_times).each do |t2|
        if overlaps?(times[t1], times[t2])
          overlapping_pairs.append([t1, t2])
          overlap_map[times[t1]] << times[t2] 
          overlap_map[times[t2]] << times[t1] # by symmetry
        end
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
    Rulp.log_level = Logger::ERROR

    begin       
      Rulp::Glpk(problem)
    rescue StandardError
      raise StandardError, 'Solution infeasible!'
    end

    # Add time and room data to classes hash
    (0...num_classes).each do |c|
      (0...num_rooms).each do |r|
        (0...num_times).each do |t|
          next unless sched[c][r][t].value
          classes[c]['time_slot'] = times[t]
          classes[c]['room_id'] = rooms[r]['id']
        end
      end
    end

    # Generate unhappiness matrix with prof ID
    unhappiness_matrix, prof_ids = generate_unhappiness_matrix(classes, instructors, hours, class_id_hash)

    # Solve the min weight perfect matching via the Hungarian algorithm
    # The library clobbers the matrix, so create a deep copy first
    copy = unhappiness_matrix.map(&:dup)
    matching = HungarianAlgorithm.new(unhappiness_matrix).process.sort

    # matching is a 2D array, where each element [i,j] represents the assignment of professsor i to class j
    # Map the course to prof_ids[prof], which gives the position of the true professor in the instructors array
    matching = matching.map { |prof, course| [classes[course], prof_ids[prof]] }.to_h
    
    total_unhappiness = 0
    curr_time = Time.now 
    classes.each do |assigned_course|
      true_prof_id = matching[assigned_course]
      course_id = assigned_course['id']
      total_unhappiness += copy[true_prof_id][class_id_hash[course_id]]
      assigned_time = assigned_course['time_slot']
      # Generate room booking for scheduled course
      RoomBooking.create(
        room_id: assigned_course['room_id'],
        time_slot_id: assigned_time[3],
        is_available: true,
        is_lab: false,
        created_at: curr_time,
        updated_at: curr_time,
        course_id: course_id,
        instructor_id: instructors[true_prof_id]['id']
      )
      # Create room bookings for given room at all conflicting timeslots
      # This manifests in the schedule and prevents the user from scheduling something that would cause conflict
      conflicting_times = overlap_map[assigned_time]
      conflicting_times.each do |time_slot|
        RoomBooking.create(
          room_id: assigned_course['room_id'],
          time_slot_id: time_slot[3],
          is_available: false,
          is_lab: false,
          created_at: curr_time,
          updated_at: curr_time,
        )
        overlap_map[assigned_time].delete(time_slot)
      end

    end
    total_unhappiness
  end

  private
    THREE_PM = Time.parse('15:00')
    NINE_AM = Time.parse('9:00')

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
  # Memory is precious, so use bit masks here
  def self.day_overlaps?(days1, days2)
    day1_mask = 0
    day2_mask = 0
    # Assume that days only contains the characters MWTRF
    days1.each_char do |c|
      day1_mask |= 1 << (c.ord - 'F'.ord)
    end
    days2.each_char do |c|
      day2_mask |= 1 << (c.ord - 'F'.ord)
    end  
    day1_mask & day2_mask != 0
  end

  def self.before_9?(time)
    start_time = time[1]
    Time.parse(start_time) <= NINE_AM
  end

  def self.after_3?(time)
    end_time = time[2]
    Time.parse(end_time) >= THREE_PM
  end

  # Move this generation to a separate function
  # Allows sched_flat to fall out of scope and get claimed by GC
  def self.init_ilp_tensor(num_classes, num_rooms, num_times)
    # Allocate ijk binary decision variables and reshape into 3D tensor
    sched_flat = Array.new(num_classes * num_rooms * num_times, &X_b)
    sched_flat.each_slice(num_times).each_slice(num_rooms).to_a
  end

  def self.reduce_hours(hours, courses_to_drop)
    # Create max heap with hour as key and index as value
    heap = Containers::MaxHeap.new 
    hours.each_with_index do |h,i|
      heap.push(h, i)
    end
    
    # Reduce hours from prof with highest number of hours
    courses_to_drop.times do
      hour = heap.next_key
      idx = heap.pop
      heap.push(hour-1, idx)
    end

    # Reconstitute modified array
    adjusted_hours = Array.new(hours.size, -1)
    until heap.empty?
      hour = heap.next_key
      idx = heap.pop
      adjusted_hours[idx] = hour
    end

    adjusted_hours
  end

  def self.generate_unhappiness_matrix(classes, instructors, hours, class_hash)
    # Because of the hour reduction scheme, we know that num_classes == num_profs, where profs are counted with multiplicity
    # Generate num_profs * num_classes matrix
    unhappiness_matrix = Array.new(classes.length) { Array.new(classes.length) { 0 } }

    # Hyperparameters for the unhappiness function
    # We choose a simple linear combination:
    # unhappiness(p,c) = time_weight * I[class c is at a bad time for prof p] + class_weight*(5-preference_level)
    # If we choose weights such that time_weight + 4*class_weight = 10, the unhappiness score is bounded between 0 and 10
    time_weight = 2
    class_weight = 2

    prof_hash = (0...instructors.length).map { |i| [instructors[i]['id'], i] }.to_h

    # Initialize the matrix based on InstructorPreference data
    # Use find_each for batching, reducing calls to DB
    InstructorPreference.find_each do |preference|
      i = class_hash[preference.course_id]
      j = prof_hash[preference.instructor_id]
      unhappiness_matrix[i][j] = class_weight * (5-preference.preference_level)
    end

    # Since row i likely doesn't correspond to prof i, keep track of underlying prof ID
    # i.e. if prof 0 has 3 courses prof_id[0...3] = 0
    curr_row = 0
    instructor_idx = 0
    prof_ids = Array.new(classes.length) {-1}
    (0...instructors.length).each do |instructor_idx|
      # Set true professor ID
      prof_ids[curr_row] = instructor_idx
      hates_mornings = !instructors[instructor_idx]['before_9']
      hates_evenings = !instructors[instructor_idx]['after_3']

      # Fill out row, comparing assigned time with temporal preference
      (0...classes.length).each do |course|
        assigned_time = classes[course]['time_slot']
        if hates_mornings && before_9?(assigned_time)
          unhappiness_matrix[curr_row][course] += time_weight
        elsif hates_evenings && after_3?(assigned_time)
          unhappiness_matrix[curr_row][course] += time_weight
        end
      end
      
      # Duplicate the row according to the professor's teaching capacity
      num_duplications = hours[instructor_idx]-1
      num_duplications.times do
        unhappiness_matrix[curr_row+1] = unhappiness_matrix[curr_row].dup 
        prof_ids[curr_row+1] = instructor_idx
        curr_row += 1 
      end

      # Move up one, since previous loop was one ahead
      curr_row += 1

    end
    # Return matrix and true ids
    [unhappiness_matrix, prof_ids]
  end

end 