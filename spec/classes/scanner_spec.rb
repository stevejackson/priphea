require 'spec_helper'
require 'benchmark'

RSpec.describe Scanner do
  before :each do
    @scanner = Scanner.new(Settings.library_path)
  end

  it "should import songs" do
    expect(Song.count).to be 0
    @scanner.scan
    expect(Song.count).to be > 0
  end

  it "should import albums" do
    expect(Album.count).to be 0
    @scanner.scan
    expect(Album.count).to be > 0
  end

  describe "Cover art cache" do
    it "should create a cache file for the cover art of an album" do
      @scanner.scan
      album = Album.first

      expect(album.cover_art_cache_file).to_not be_nil

      file = File.join(Settings.cover_art_cache, album.cover_art_cache_file)
      expect(File.exists?(file)).to be true
    end
  end

  describe "Performance" do
    it "should be reasonably fast per song" do
      expected_per_song = 140 # in milliseconds

      result = Benchmark.realtime do
        @scanner.scan
      end

      result *= 1000 # convert to milliseconds

      songs_scanned = Song.count

      result_per_song = result / songs_scanned

      expect(result_per_song).to be < expected_per_song
    end
  end

end
