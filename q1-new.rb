# 1. How would you (in a controller method) assign to @country the Country named ‘France’?
@country = Country.find_by_name("France")

# 2. How would you assign to @cities an Array of all the cities in France?
@cities = @country.cities

# 3. How would you assign to @bars an Array of all the bars in France?
@bars = Bar.where(:id => @cities).all
# OR
# Edit country.rb
# Country has_many :bars, :through => :cities
@bars = @country.bars

# 4. How would you assign to @directory an Array of the names of all the bars in France, sorted?
@directory = Bar.where(:id => @cities).pluck(:name).sort

# 5. Do any of the above answer change if there are 400 cities?
# No.

# 6. How about if there are 20,000 bars?
# Yes.
# Answer 4
@directory = Bar.where(:id => @cities).order("bars.name ASC").pluck(:name)