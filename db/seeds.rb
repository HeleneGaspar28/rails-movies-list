# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
require "open-uri"
require "json"

puts "Cleaning database..."
Movie.destroy_all
List.destroy_all
Bookmark.destroy_all

# Top rated movies endpoint (proxy, no API key needed)
url = "https://tmdb.lewagon.com/movie/top_rated"

puts "Fetching movies..."
serialized = URI.open(url).read
data = JSON.parse(serialized)

results = data["results"] || []

# 1) Create movies (your existing TMDB code)
puts "Creating movies..."
results.each do |movie|
  Movie.create!(
    title:       movie["title"],
    overview:    movie["overview"],
    rating:      movie["vote_average"],
    poster_url:  "https://image.tmdb.org/t/p/w500#{movie['poster_path']}"
  )
end
puts "Movies: #{Movie.count}"

# 2) Create lists
puts "Creating lists..."
drama    = List.create!(name: "Drama")
thriller = List.create!(name: "Thriller")
comedy   = List.create!(name: "Comedy")
lists = [drama, thriller, comedy]
puts "Lists: #{List.count}"

# 3) Create bookmarks (movies ↔ lists)
puts "Creating bookmarks..."
# ensure every list gets some movies
lists.each do |list|
  Movie.order("RANDOM()").limit(5).each do |movie|
    Bookmark.create!(list: list, movie: movie, comment: "Such a good movie OMG!")
  end
end

# optional: ensure every movie is in at least one list
Movie.find_each do |movie|
  next if movie.lists.exists?
  Bookmark.create!(list: lists.sample, movie: movie, comment: "Auto-assign")
end

puts "Bookmarks: #{Bookmark.count}"
puts "Done."
