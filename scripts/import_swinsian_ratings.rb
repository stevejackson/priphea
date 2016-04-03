# usage: rails runner scripts/import_swinsian_ratings.rb
#
# Must have "settings.swinsian_library" path set.
# The library.sqlite file contains the data.
#
# track table contains the songs.
# track.path is like "/Volumes/blah/blah.mp3"
# track.rating is 0 1 2 3 4 5

require 'sequel'
require 'rails'

DB = Sequel.sqlite("#{Settings.swinsian_library}")

puts "Swinsian total #{DB[:track].count} tracks"

with_ratings = []
DB[:track].each do |track|
  if track[:rating] > 0
    with_ratings << track
  end
end

puts "Swinsian total #{with_ratings.length} songs with ratings"

matches = []
with_ratings.each do |track|
  swinsian_track = track[:path].force_encoding('UTF-8')
  swinsian_track.unicode_normalize! # ruby 2.2 method
  puts "Swinsian track that has a rating: #{swinsian_track.inspect}"

  # check if this song exists in Priphea's database.
  if Song.where({ full_path: swinsian_track }).exists?
    song = Song.where({ full_path: swinsian_track }).first
    puts "Found track in Priphea database, updating rating: #{song.id}"
    song.rating = track[:rating] * 2 * 10 # convert "2" to "20" (out of 5 to out of 100)
    song.save!

    matches << song
  else
    puts "That file wasn't found in Priphea database."
  end
end

puts "Imported total of #{matches.length} matches"
