# Question #3 (General)

# Use whatever language you are comfortable in to solve this problem.
# An ant is walking on the squares of a 5x5 grid - it starts in the center square.

# Each second, it will choose (with equal probability) to do one of the following:

# Move north one square
# Move south one square
# Move east one square
# Move west one square
# Do not move
# If it cannot perform the action it has decided on (move west while on the west edge, for example), it sits in place.

# After one second, it has a 20% chance of being in the center, and a 20% chance of being in each adjacent square. (and a 0% chance of being in any other square on the board).

# What is the probability that the ant is on the center square after 15 seconds?
# What is the probability that the ant is on one of the outermost squares after 1 hour?
# You may ignore floating point error accumulation.

require 'matrix'

matrix_rows = []
columns = [*1..5]
ids = []
rows = [*1..5]
squares = []

# Populate the hash mapping
id = 0
rows.each do |row|
  columns.each do |column|
    if row == 1 || row == rows.count || column == 1 || column == columns.count
  	  edge = true
    else
  	  edge = false
  	end
    squares << {:id => id, :row => row, :column => column, :edge? => edge}
	ids << id
	id += 1
  end
end



# Create the probability matrix
squares.each do |current_square|
  #Initialize the chance to remain at current square
  chance_to_self = 0.2
  
  # Create a matrix row
  matrix_row = squares.size.times.collect{0}
  
  # Move North  
  northern_square=squares.select{|square| square[:row]==(current_square[:row]+1) and square[:column]==current_square[:column]}.first
  if !northern_square.nil?
    matrix_row[northern_square[:id]] = 0.2
  else
    chance_to_self += 0.2
  end
  
  # Move South  
  southern_square=squares.select{|square| square[:row]==(current_square[:row]-1) and square[:column]==current_square[:column]}.first
  if !southern_square.nil?
    matrix_row[southern_square[:id]] = 0.2
  else
    chance_to_self += 0.2
  end
  
  # Move East  
  eastern_square=squares.select{|square| square[:row]==current_square[:row] and square[:column]==(current_square[:column]+1)}.first
  if !eastern_square.nil?
    matrix_row[eastern_square[:id]] = 0.2
  else
    chance_to_self += 0.2
  end
  
  # Move West  
  western_square=squares.select{|square| square[:row]==current_square[:row] and square[:column]==(current_square[:column]-1)}.first
  if !western_square.nil?
    matrix_row[western_square[:id]] = 0.2
  else
    chance_to_self += 0.2
  end
    
  # Set Chance to Self	
  matrix_row[current_square[:id]]=chance_to_self
  
  # Append new matrix row
  matrix_rows << matrix_row
end

test_matrix = Matrix[*matrix_rows] 

# Answer 1
p "The probability that the ant is on the center square after 15 seconds is about #{(test_matrix**15)[3,3].round(3)*100}%"

# Answer 2
p "The probability that the ant is on one of the outermost squares after 1 hour is about #{((test_matrix**3600)[0,0]*16).round(2)*100}%"

# Additional Comments
# Answer 2 is equal to the steady state probability distribution. 
# I will demonstrate by solving the system of equations below.
matrix = matrix_rows

# Generate the pi constraint. '2' is used in the final column because when the identity matrix is subtracted,
# it will become '1' like the other columns in the pi constraint row.
pi_constraint = ids.count.times.collect {|i| i < ids.count-1 ? 1:2}

# Replace a constraint with pi constraint to keep the matrix square and thus invertible.
matrix[ids.count-1] = pi_constraint

# Transform a 2D array into a matrix
coefficients = Matrix[*matrix]

# Subtract the identity matrix
coefficients = coefficients - Matrix.I(ids.count)

# Set the row flow constraints to be equal to 0, set the final pi constraint to be equal to 1 
constants = ids.count.times.collect {|i| i < ids.count-1 ? [0]:[1]}

# Transform a 2D array into a matrix
constants = Matrix[*constants]

# Solve the system equations to compute the steady state matrix
steady_state_matrix = coefficients.inverse*constants

# Print 1 hour distribution
test_matrix_vector = ids.count.times.collect{|i| (test_matrix**3600)[i,0].round(2) }
p "The probability distribution after 1 hour is #{test_matrix_vector}"


# Print the steady state distribution
steady_state_probability_distribution = constants.count.times.collect{|i| steady_state_matrix[i,0].round(2) }
p "The steady state probability distribution is #{steady_state_probability_distribution}"

# Final Notes:
# You could also use discrete event simulation and count the transitions using brute force, but simple Markov Chain analyis is more efficient for this problem.

