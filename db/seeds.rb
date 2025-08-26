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

# Top rated movies endpoint (proxy, no API key needed)
url = "https://tmdb.lewagon.com/movie/top_rated"

puts "Fetching movies..."
serialized = URI.open(url).read
data = JSON.parse(serialized)

results = data["results"] || []

puts "Creating movies..."
results.each do |movie|
  Movie.create!(
    title:       movie["title"],
    overview:    movie["overview"],
    rating:      movie["vote_average"],
    # Build poster URL from poster_path using TMDB image CDN (works with the proxy)
    poster_url:  "https://image.tmdb.org/t/p/w500#{movie['poster_path']}"
  )
end

puts "Done. Created #{Movie.count} movies."
