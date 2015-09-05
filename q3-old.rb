# This depends on the GNU Linear Programming Kit. I've given instructions on how to download, configure, and build the native extensions below.

# Setup
# wget http://ftp.gnu.org/gnu/glpk/glpk-4.44.tar.gz
# tar zxf glpk-4.44.tar.gz
# cd ./glpk-4.44
# ./configure --enable-shared && sudo make clean && sudo make && sudo make install
# gem install rglpk

# Method
# Integer Program
# Paramaters:
# Stages - s := [0..S]
# Positions - p := [0..P(s)]
# Decision Variables:
# X(s,p) := the decision to use the node at position p at stage s.
# Constraints:
# 1. All decision variables are binary.
# 2. Only one position may be active per stage.
# 3. Dynamic flow - Only nodes in "adjacent" positions may be traveled to from the previous stage.

# Implementation
@stages = [*0..14]
@triangle = []
@hashes = []
@keys = []
@values = 
[
75,    
95,    64,    
17,    47,    82,    
18,    35,    87,    10,    
20,    4,    82,    47,    65,    
19,    1,    23,    75,    3,    34,    
88,    2,    77,    73,    7,    63,    67,    
99,    65,    4,    28,    6,    16,    70,    92,    
41,    41,    26,    56,    83,    40,    80,    70,    33,    
41,    48,    72,    33,    47,    32,    37,    16,    94,    29,    
53,    71,    44,    65,    25,    43,    91,    52,    97,    51,    14,    
70,    11,    33,    28,    77,    73,    17,    78,    39,    68,    17,    57,    
91,    71,    52,    38,    17,    14,    91,    43,    58,    50,    27,    29,    48,    
63,    66,    4,    68,    89,    53,    67,    30,    73,    16,    69,    87,    40,    31,    
4,    62,    98,    27,    23,    9,    70,    98,    73,    93,    38,    53,    60,    4,    23
]

@off_set = 0
@stages.each do |stage|
    stage_values = @values[(@off_set)..(@off_set+stage)]   
    [*0..stage].each {|position| @keys.push([stage,position])}
    @off_set = @off_set + 1 + stage
end

[*0..(@values.size-1)].each do |i|
 hash = { "column_id" => i, "value" => @values[i], "stage" => @keys[i][0], "position" => @keys[i][1]  }
 @hashes.push(hash)
end

@arguments = []
[*0..(@values.size-1)].each do |i|
 argument = { "column_id" => i, "value" => @values[i], "stage" => @keys[i][0], "position" => @keys[i][1]  }
 @arguments.push(argument)
end


require 'rglpk'

p = Rglpk::Problem.new
p.name = "Emcien Max Flow Integer Program" 
p.obj.dir = Rglpk::GLP_MAX

cols = p.add_cols(@values.size)
rows = p.add_rows(@stages.size+@values.size-1)
#rows = p.add_rows(@stages.size)

#Stage Constraints
@stages.each {|stage| rows[stage].set_bounds(Rglpk::GLP_UP, 0, 1)}

#Value Constraints
# Note: Must offset the rows by the count of the stages, since the stage constraint was implemented first
[*1..@values.size-2].each {|value_id| rows[@stages.size+value_id].set_bounds(Rglpk::GLP_UP, 0, 0)}

#Set the objective function co-efficients
p.obj.coefs = @values

#Initialize the constraint matrix
@constraint_matrix = []

# TO DO:
# Add the stage constraint coefficients
[*0..@stages.size-1].each do |stage_id|
  stage_constraint = []
  [*0..@values.size-1].each do |col_id|
    @hashes[col_id]["stage"]==@stages[stage_id] ? stage_constraint.push(1) : stage_constraint.push(0)
  end
  @constraint_matrix = @constraint_matrix + stage_constraint
end

# Add the flow constraint coefficients
[*0..@values.size-1].each do |value_id|  
  current_hash = @hashes.select {|hash| hash["column_id"] == value_id}.first
  candidate_hash_one = @hashes.select {|hash| hash["stage"] == current_hash["stage"]-1 and hash["position"] == current_hash["position"]-1}.first
  candidate_hash_two = @hashes.select {|hash| hash["stage"] == current_hash["stage"]-1 and hash["position"] == current_hash["position"]}.first
  flow_constraint = @values.size.times.collect{0}
  flow_constraint[current_hash["column_id"]]=1
  if !candidate_hash_one.nil?
    flow_constraint[candidate_hash_one["column_id"]]=-1
  end
  if !candidate_hash_two.nil?
    flow_constraint[candidate_hash_two["column_id"]]=-1
  end
  if value_id==0
  else
    @constraint_matrix = @constraint_matrix + flow_constraint 
  end
end

p.set_matrix(@constraint_matrix)

# Make all decision variables binary
p.cols.each{|c| c.kind = Rglpk::GLP_BV}
solution_method = :mip
value_method = :mip_val
p.send(solution_method, {:presolve => Rglpk::GLP_ON})
p.mip
z = p.obj.get

@sum = 0
p "Path"
[*0..@values.size-1].each do |i| 
  if cols[i].mip_val == 1 
  p "#{@keys[i]}: #{@values[i]}"
  @sum = @sum + @values[i]
  else
  end
end
p "Total Cost: #{@sum}"

# Solution
# [Stage, Position]: Cost
# [0, 0]: 75
# [1, 1]: 64
# [2, 2]: 82
# [3, 2]: 87
# [4, 2]: 82
# [5, 3]: 75
# [6, 3]: 73
# [7, 3]: 28
# [8, 4]: 83
# [9, 5]: 32
# [10, 6]: 91
# [11, 7]: 78
# [12, 8]: 58
# [13, 8]: 73
# [14, 9]: 93
# Total Cost for Optimal Path: 1074

# Notes:
# To save on computation time, the first node may be omitted from the optimization, because it will be used in every solution.
# May want to recursively build the triangle.


