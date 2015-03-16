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
