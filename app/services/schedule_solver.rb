# frozen_string_literal: true
require 'rulp'
require 'hungarian_algorithm'

class ScheduleSolver

  def self.solve(classes, rooms, times, professors, capacities, enrollments, locks, unhappiness_matrix)    
    num_classes = classes.length 
    num_rooms = rooms.length 
    num_times = times.length 
    num_professors = professors.length 

    puts "classes: #{num_classes}"
    puts "rooms: #{num_rooms}"
    puts "times: #{num_times}"
    puts "profs: #{num_professors}"

    # Allocate ijk binary decision variables
    sched_flat = Array.new(num_classes * num_rooms * num_times, &X_b)

    # Reshape into a 3D tensor
    # i.e. sched[i][j][k] = 1 is class i is located at room j for time k
    sched = sched_flat.each_slice(num_times).each_slice(num_rooms).to_a

    # Create objective function
    # Minimize the number of empty seats in a full section
    objective = sched.map.with_index do |mat, c|
      mat.map.with_index do |row, r|
        row.map.with_index do |val, t|
            val * (capacities[r] - enrollments[c])
        end.reduce(:+)
      end.reduce(:+)
    end.reduce(:+)

    # Constraint #1: Room capacity >= class enrollment
    cap_constraints = 
    sched.map.with_index do |mat, c|
      mat.map.with_index do |row, r|
        row.map.with_index do |val, t|
          val * (capacities[r] - enrollments[c]) >= 0
        end
      end
    end

    # Constraint #2: No two classes can share one room at the same time
    # For some reason, the constraints can't be generated using map
    # Create the array at the beginning, and append individually
    share_constraints = []
    (0...num_rooms).each do |r|
      (0...num_times).each do |t|
        share_constraints.append((0...num_classes).map{|c| sched[c][r][t]}.reduce(:+) <= 1)
      end
    end

    # Constraint #3: Every class has exactly one assigned room and time
    place_constraints = 
    sched.map do |mat|
      mat.map{|row| row.reduce(:+)}.reduce(:+) == 1
    end

    # Constraint #4: Respect locked courses
    # locks[i] = (class, room, time) triplet
    lock_constraints = 
    locks.each do |trio|
      # For unknown reasons, I can't write sched[c][r][t] == 1
      # Ruby will evaluate this as a boolean expression, instead of the constraint
      # Introduce a dummy variable to prevent this from happening
      # If their sum is two => sched[c][r][t] must be 1
      sched[trio[0]][trio[1]][trio[2]] + Dummy_b == 2
    end

    # Constraint #5: Courses that require special designations get rooms that meet them
    # TODO

    # Constraint #6: Ensure rooms are not scheduled at overlapping times
    # Go through all pairs of time slots and find those that overlap
    overlapping_pairs = []
    (0...num_times).each do |t1|
      (t1...num_times).each do |t2|
        if overlaps?(times[t1], times[t2])
          overlapping_pairs.append([t1, t2])
        end
      end
    end

    # For each pair of overlapping times, ensure that at most one is used
    overlap_constraints = []
    (0...num_classes).each do |c|
      (0...num_rooms).each do |r|
        overlapping_pairs.each do |t1,t2|
          overlap_constraints.append(sched[c][r][t1] + sched[c][r][t2] <= 1)
        end
      end
    end

    # Consolidate constraints
    constraints = cap_constraints + share_constraints + place_constraints + lock_constraints + overlap_constraints

    # Form ILP and solve
    problem = Rulp::Min(objective)
    problem[constraints]
    Rulp::Glpk(problem)

    # Now that the courses have been assigned rooms and times, we now add professors
    # This can be viewed as a bipartite matching (see ILP doc)

    # Solve the min weight perfect matching via the Hungarian algorithm
    # While extensions to nonperfect matchings exist for HA, this particular library doesn't support them
    # The library modifies the matrix, so create a deep copy first
    copy = unhappiness_matrix.map{ |row| row.dup}
    matching = HungarianAlgorithm.new(unhappiness_matrix).process.sort

    # matching is a 2D array, where each element [i,j] represents the assignment of professsor i to class j
    # Flatten this to a simpler map of profs to classes
    # i.e have matching[i] = j instead of matching[i] = [i,j]
    matching = matching.map{ |u,v| v}

    # Generate assignment as a map
    # Map room/timeslot ID => course/professor
    assignment = {}
    (0...num_classes).each do |c|
      class_name = classes[c]
      assigned_prof = professors[matching.index(c)]
      (0...num_rooms).each do |r|
        (0...num_times).each do |t|
          if sched[c][r][t].value
            key = rooms[r] + "/" + times[t][0] + "/" + times[t][1] + "-" + times[t][2]
            assignment[key] = "#{class_name}/#{assigned_prof}"
            next
          end
        end
      end
    end

    return assignment
  end

  # Find if two timeslots overlap
  # time1 = [days, start_time, end_time]
  def self.overlaps?(time1, time2)
    days1 = time1[0]
    days2 = time2[0]
    if not day_overlaps?(days1, days2)
      return false
    end
    start1 = time1[1]
    start2 = time2[1]
    end1 = time1[2]
    end2 = time2[2]
    return (start1 < start2 && start2 < end1) || (start2 < start1 && start1 < end2)
  end

  # Check if two times overlap on at least one day
  def self.day_overlaps?(days1, days2)
    d1 = days1.scan(/TR|M|T|W|F/)
    d2 = days2.scan(/TR|M|T|W|F/)
    !(d1 & d2).empty?
  end


end
