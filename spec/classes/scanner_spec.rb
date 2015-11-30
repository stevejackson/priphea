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
    before :each do
      FileUtils.rm_rf(Settings.cover_art_cache)
    end

    it "should create a cache file for the cover art of an album" do
      @scanner.scan
      album = Album.first

      expect(album.cover_art_cache_file).to_not be_nil

      file = File.join(Settings.cover_art_cache, album.cover_art_cache_file)
      expect(File.exists?(file)).to be true
    end

    describe "should be able to create cache file out of embedded file art" do
      it "FLAC" do
        file = File.join("spec", "data", "test_songs", "embedded-art.flac")

        song = Song.build_from_file(file)
        song.save!

        song.album.update_cover_art_cache

        expect(song.album.cover_art_cache_file).to_not be_nil

        file = File.join(Settings.cover_art_cache, song.album.cover_art_cache_file)
        expect(File.exists?(file)).to be true
      end

      it "MP3" do
        file = File.join("spec", "data", "test_songs", "embedded-art.mp3")

        song = Song.build_from_file(file)
        song.save!

        song.album.update_cover_art_cache

        puts song.inspect
        puts song.album.inspect

        expect(song.album.cover_art_cache_file).to_not be_nil

        file = File.join(Settings.cover_art_cache, song.album.cover_art_cache_file)
        expect(File.exists?(file)).to be true
      end
    end
  end

  describe "Performance" do
    it "should be reasonably fast per song" do
      expected_per_song = 500 # in milliseconds

      result = Benchmark.realtime do
        @scanner.scan
      end

      result *= 1000 # convert to milliseconds

      songs_scanned = Song.count

      result_per_song = result / songs_scanned

      expect(result_per_song).to be < expected_per_song
    end
  end

  describe "Metadata" do

    before :each do
      @scanner.scan

      @mp3 = Song.where({ title: "The Labyrinth" }).first
      @flac = Song.where({ title: "Sea-Cat Walkway [Boy Meets Girl]" }).first
    end

    it "duration" do
      expect(@mp3.duration).to eq("05:54")
      expect(@flac.duration).to eq("04:07")
    end

  end

  describe "Handling rescanning of same files" do

    before :each do
      @scanner = Scanner.new(Settings.library_path)
    end

    it "should not recreate same files based on identical full_path" do
      @scanner.scan

      before_song_count = Song.count

      @scanner.scan

      expect(Song.count).to equal(before_song_count)
    end

    # it "should be able to scan files, rate a song, change song title in metadata, rescan, and retain rating and have changed title" do
    #   @scanner.scan
    #
    #
    #   song_path = "spec/data/fakemusiclib/test_rescan.mp3"
    #   song_full_path = File.join(Rails.root, song_path)
    #
    #   new_rating = Random.rand(100)
    #
    #   song = Song.find_by(full_path: song_path)
    #   song.rating = new_rating
    #   song.save!
    #
    #   expect(song.rating).to eq(new_rating)
    #   title_before = song.title
    #
    #   # need to change song title in metadata, then reimport it
    #   title_after = "TestTitle_#{Random.rand(100000)}"
    #
    #   puts "TitleBefore: #{title_before}"
    #   puts "TitleAfter: #{title_after}"
    #
    #   song = Song.find_by(full_path: song_path)
    #   expect(song.title).to eq(title_after)
    #   expect(song.rating).to eq(new_rating)
    #
    # end
  end


end
