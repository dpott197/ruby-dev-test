require 'bigdecimal'

numbers = 1..100000

# Answer #1 - Even Divisibles
divisibles = numbers.find_all{|i| i % 19 == 0}
p "There are #{divisibles.count} numbers in S."
# => "There are 5263 numbers in S."

# Answer #2 - Perfect Squares
squares = divisibles.find_all{|i| BigDecimal(i.to_s) % Math.sqrt(BigDecimal.new(i.to_s)) == 0}
p "There are #{squares.count} numbers that are perfect squares in S."
# => "There are 16 numbers that are perfect squares in S."

# Answer #3 - Reflections
strings = divisibles.collect{|i| i.to_s}
reversed_strings = divisibles.collect{|i| i.to_s.reverse}
reflections = strings & reversed_strings
p "There are #{reflections.count} numbers that have reflections that is also in S."
# => "There are 250 numbers that have reflections that are also in S."

# Answer #4 - Multiples
multiples = []
divisibles.each do |d1|
  divisibles.each do |d2|
    multiples << d1 * d2 
  end
end
multiples = multiples & divisibles
p "There are #{multiples.count} numbers that can be multiplied by some other number in S to produce a third number in S."
# => "There are 277 numbers that can multiply with another number in S to produce a third number in S."
