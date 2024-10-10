require 'rulp'

num_classes = 4  # classes
num_rooms = 3  # rooms
num_times = 2  # timeslots

# Define the sets for classes, rooms, and time slots
# NOTE: These need to be the ranges, not the actual class values
# Otherwise, we need to change the classes.each et al
classes = (0...num_classes).to_a 
rooms = (0...num_rooms).to_a   
times = (0...num_times).to_a   

# Define enrollments and room capacities
enrollments = Array.new(num_classes) { rand(30..50) }
capacities = Array.new(num_rooms) { rand(40..80) }

# Allocate ijk binary decision variables
X_flat = Array.new(num_classes * num_rooms * num_times, &X_b)

# Reshape this into a 3D tensor
# i.e. X[i][j][k] = 1 is class i is located at room j for time k
X = X_flat.each_slice(num_times).each_slice(num_rooms).to_a

# Create objective function
objective = X.map.with_index do |mat, c|
  mat.map.with_index do |row, r|
    row.map.with_index do |val, t|
        # puts "Class #{c}, Room #{r}, Time #{t}"
        val * (capacities[r] - enrollments[c])
    end.reduce(:+)
  end.reduce(:+)
end.reduce(:+)

# Form ILP
problem = Rulp::Min(objective)

# Constraint #1: Room capacity >= class enrollment
cap_constraints = 
X.map.with_index do |mat, c|
  mat.map.with_index do |row, r|
    row.map.with_index do |val, t|
      # puts "Class #{c} (sz #{enrollments[c]}), Room #{r} (cap #{capacities[r]}), Time #{t}"
      val * (capacities[r] - enrollments[c]) >= 0
    end
  end
end

# Constraint #2: No two classes can share one room at the same time
# For some reason, the constraints can't be generated like the other two
# Create the array at the beginning, and append individually
share_constraints = Array.new()
rooms.each do |r|
  times.each do |t|
    share_constraints.append(classes.map{|c| X[c][r][t]}.reduce(:+) <= 1)
  end
end

# Constraint #3: Every class has exactly one assigned room and time
place_constraints = 
X.map do |mat|
  mat.map{|row| row.inject(:+)}.inject(:+) == 1
end

# TODO: Add constraint that courses that require lab rooms are placed in lab classes

# Consolidate constraints, add to model, and solve
constraints = cap_constraints + share_constraints + place_constraints
problem[constraints]
Rulp::Glpk(problem)

# Print solution
(0...num_classes).each do |c|
  (0...num_rooms).each do |r|
    (0...num_times).each do |t|
      if X[c][r][t].value
        puts "Class #{c} (size #{enrollments[c]}) assigned to room #{r} (cap #{capacities[r]}) at time #{t}"
      end
    end
  end
end
