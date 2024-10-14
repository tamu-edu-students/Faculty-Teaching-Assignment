require 'rulp'
require 'hungarian_algorithm'

# Designate number of classes, rooms, and timeslots
num_classes = 50
num_rooms = 15
num_times = 8

# Define enrollments and room capacities
enrollments = Array.new(num_classes) { rand(30..50) }
capacities = Array.new(num_rooms) { rand(40..80) }

# Allocate ijk binary decision variables
X_flat = Array.new(num_classes * num_rooms * num_times, &X_b)

# Reshape into a 3D tensor
# i.e. X[i][j][k] = 1 is class i is located at room j for time k
X = X_flat.each_slice(num_times).each_slice(num_rooms).to_a

# Create objective function
# Minimize the number of empty seats in a full section
objective = X.map.with_index do |mat, c|
  mat.map.with_index do |row, r|
    row.map.with_index do |val, t|
        val * (capacities[r] - enrollments[c])
    end.reduce(:+)
  end.reduce(:+)
end.reduce(:+)

# Constraint #1: Room capacity >= class enrollment
cap_constraints = 
X.map.with_index do |mat, c|
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
    share_constraints.append((0...num_classes).map{|c| X[c][r][t]}.reduce(:+) <= 1)
  end
end

# Constraint #3: Every class has exactly one assigned room and time
place_constraints = 
X.map do |mat|
  mat.map{|row| row.reduce(:+)}.reduce(:+) == 1
end

# Constraint #4: Respect locked courses
# Have three parallel arrays, where each index is a class/room/time triplet
num_locks = 3
locked_classes = Array.new(num_locks) {rand(0...num_classes)}
locked_rooms = Array.new(num_locks) {rand(0...num_rooms)}
locked_times = Array.new(num_locks) {rand(0...num_times)}

lock_constraints = 
(0...num_locks).map do |i|
  # For unknown reasons, I can't write X[c][r][t] == 1
  # Ruby will evaluate this as a boolean expression, instead of the constraint
  # Introduce a dummy variable to prevent this from happening
  # If their sum is two => X[c][r][t] must be 1
  X[locked_classes[i]][locked_rooms[i]][locked_times[i]] + Dummy_b == 2
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

# FIXME: This isn't necessarily true
# Will add duplication of profs if profs << classes
num_professors = num_classes

# Construct unhappiness matrix, where UM[i][j] is the unhappiness of professor i if assigned to class j
# Garbage values for now
unhappiness_matrix = Array.new(num_professors) {Array.new(num_classes) { rand(0..10)}}

# Solve the min weight perfect matching via the Hungarian algorithm
# While extensions to nonperfect matchings exist for HA, this particular library doesn't support them
matching = HungarianAlgorithm.new(unhappiness_matrix).process.sort

# matching is a 2D array, where each element [i,j] represents the assignment of professsor i to class j
# Flatten this to a simpler map of profs to classes
# i.e have assignment[i] = j instead of matching[i] = [i,j]
assignment = matching.map{ |u,v| v}

# Print solution
(0...num_classes).each do |c|
  (0...num_rooms).each do |r|
    (0...num_times).each do |t|
      if X[c][r][t].value
        puts "Class #{c} (size #{enrollments[c]}) assigned to room #{r} (cap #{capacities[r]}) at time #{t} to professor #{assignment[c]}"
      end
    end
  end
end