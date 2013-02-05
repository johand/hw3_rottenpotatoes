# Add a declarative step here for populating the DB with movies.

Given /the following movies exist/ do |movies_table|
  movies_table.hashes.each do |movie|
    # each returned element will be a hash whose key is the table header.
    # you should arrange to add that movie to the database here.
    Movie.create!(movie)
  end
end

# Make sure that one string (regexp) occurs before or after another one
#   on the same page

Then /I should see "(.*)" before "(.*)"/ do |e1, e2|
  #  ensure that that e1 occurs before e2.
  #  page.body is the entire content of the page as a string.
  assert page.body =~ /(.)*#{Regexp.escape(e1)}(.)*#{Regexp.escape(e2)}/im
end

# Make it easier to express checking or unchecking several boxes at once
#  "When I uncheck the following ratings: PG, G, R"
#  "When I check the following ratings: G"

When /I (un)?check the following ratings: (.*)/ do |uncheck, rating_list|
  # HINT: use String#split to split up the rating_list, then
  #   iterate over the ratings and reuse the "When I check..." or
  #   "When I uncheck..." steps in lines 89-95 of web_steps.rb
  ratings = rating_list.split(%r{,\s*})
  ratings.each do |rating|
    if uncheck
      steps (%Q(When I uncheck "ratings[#{rating}]"))
    else
      steps (%Q(When I check "ratings[#{rating}]"))
    end
  end
end

Then /I should see all of the movies/ do
  numberOfRows = page.all('table tbody tr').size
  numberOfMovies = Movie.find(:all).count
  assert_equal numberOfMovies, numberOfRows
end

Then /I should see no movies/ do
  numberOfRows = page.all('table tbody tr').size
  assert_equal 0, numberOfRows
end

Then /the movies should be sorted alphabetically/ do
  check_order Movie.all(:order => :title)
end

def check_order(sortedList)
  sortedList.each_cons(2) do |x,y|
    steps %Q(Then I should see "#{x.title}" before "#{y.title}")
  end
end

When /all the movies are displayed/ do
  steps "When I check the following ratings: PG, R, G, PG-13"
  steps "And I press \"Refresh\""
end

When /the movies should be sorted in increasing order of release date/ do
  check_order Movie.all(:order => :release_date) 
end
