(1..100).each do |i| 
  if ( i % 3 == 0 ) & ( i % 5 == 0 ) 
    print "fizzbuzz"
  elsif i % 3==0
    print "fizz"
  elsif i % 5 == 0
    print "buzz"
  else
    print i
  end
end
