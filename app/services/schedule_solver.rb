# frozen_string_literal: true
require 'rulp'
require 'hungarian_algorithm'

class ScheduleSolver

  def self.solve(classes, rooms, times, professors, capacities, enrollments, num_locks, unhappiness_matrix)    
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
    share_constraints = Array.new()
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
    # Have three parallel arrays, where each index is a class/room/time triplet
    # TODO: These need to be parameters, but will be randomly generated for now
    locked_classes = Array.new(num_locks) {rand(0...num_classes)}
    locked_rooms = Array.new(num_locks) {rand(0...num_rooms)}
    locked_times = Array.new(num_locks) {rand(0...num_times)}

    lock_constraints = 
    (0...num_locks).map do |i|
      # For unknown reasons, I can't write sched[c][r][t] == 1
      # Ruby will evaluate this as a boolean expression, instead of the constraint
      # Introduce a dummy variable to prevent this from happening
      # If their sum is two => sched[c][r][t] must be 1
      sched[locked_classes[i]][locked_rooms[i]][locked_times[i]] + Dummy_b == 2
    end

    # Constraint #5: Courses that require special designations get rooms that meet them
    # TODO

    # Consolidate constraints
    constraints = cap_constraints + share_constraints + place_constraints + lock_constraints

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
    puts unhappiness_matrix.inspect
    matching = HungarianAlgorithm.new(unhappiness_matrix).process.sort

    # matching is a 2D array, where each element [i,j] represents the assignment of professsor i to class j
    # Flatten this to a simpler map of profs to classes
    # i.e have matching[i] = j instead of matching[i] = [i,j]
    matching = matching.map{ |u,v| v}
    puts matching.inspect 
    
    assignment = {}
    (0..num_classes).each do |c|
      class_name = classes[c]
      assigned_prof = professors[matching.index(c)]
      (0..num_rooms).each do |r|
        (0..num_times).each do |t|
          if sched[c][r][t] == 1
            assignment[class_name] = "#{rooms[r]}/#{times[t]}/#{assigned_prof}"
            next
          end
        end
      end
    end

    puts assignment.inspect
    return assignment
  end

end
