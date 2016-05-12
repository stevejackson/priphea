require 'spec_helper'
require 'benchmark'

describe LibraryScanner, file_cleaning: :full do
  before :each do
    @scanner = LibraryScanner.new(Settings.library_path)
  end

  it "should import songs" do
    expect {
      @scanner.scan
    }.to change { Song.count }
  end

  it "should import albums" do
    expect {
      @scanner.scan
    }.to change { Album.count }
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

        song = Song.build_song_from_file(file)
        song.save!

        CoverArtUpdater.new(song.album).update_cover_art

        expect(song.album.cover_art_cache_file).to_not be_nil

        file = File.join(Settings.cover_art_cache, song.album.cover_art_cache_file)
        expect(File.exists?(file)).to be true
      end

      it "MP3" do
        file = File.join("spec", "data", "test_songs", "embedded-art.mp3")

        song = Song.build_song_from_file(file)
        song.save!

        CoverArtUpdater.new(song.album).update_cover_art

        expect(song.album.cover_art_cache_file).to_not be_nil

        file = File.join(Settings.cover_art_cache, song.album.cover_art_cache_file)
        expect(File.exists?(file)).to be true
      end
    end
  end

  describe "Performance" do
    def benchmark_scanner(expected_per_song:, deep:, repeat: 8)
      result = Benchmark.realtime do
        repeat.times do
          @scanner.scan(deep)
        end
      end

      result *= 1000 # convert to milliseconds

      songs_scanned = Song.count

      result_per_song = result.to_f / (songs_scanned.to_f * repeat.to_f)

      Rails.logger.debug "Expected per song: #{expected_per_song}, result: #{result_per_song.inspect}"

      expect(result_per_song).to be < expected_per_song
    end

    it "should be reasonably fast per song on deep scan" do
      benchmark_scanner(expected_per_song: 400, deep: true)
    end

    it "should be reasonably fast per song on second, quick scan" do
      @scanner.scan
      benchmark_scanner(expected_per_song: 200, deep: false)
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
      @scanner = LibraryScanner.new(Settings.library_path)
    end

    it "should not recreate same files based on identical full_path" do
      @scanner.scan

      before_song_count = Song.count

      @scanner.scan

      expect(Song.count).to equal(before_song_count)
    end

    it "should be able to scan files, rate a song, change song title in metadata, rescan, and retain rating and have changed title" do
      @scanner.scan

      song_path = "spec/data/test_songs/fakemusiclib/mp3-test.mp3"

      new_rating = Random.rand(100)

      song = Song.find_by(full_path: song_path)
      song.rating = new_rating
      song.save!

      expect(song.rating).to eq(new_rating)

      # need to change song title in metadata, then reimport it
      title_after = "TestTitle_#{Random.rand(100000)}"
      AudioMetadata::write_tag(song.full_path, "title", title_after)

      @scanner.scan

      song = Song.find_by(full_path: song_path)
      expect(song.title).to eq(title_after)
      expect(song.rating).to eq(new_rating)
    end

    it "should be able to scan files, rate a song, move file to new location, rescan, and retain the same song/rating" do
      @scanner.scan

      before_song_count = Song.active.count

      song_path = File.join(Settings.library_path, "mp3-test.mp3")

      new_rating = Random.rand(100)

      # change rating of song
      song = Song.find_by(full_path: song_path)
      song.rating = new_rating
      song.save!

      # rename the file in the filesystem, force update its mtime
      new_filename = File.join(Settings.library_path, "0123.mp3")
      FileUtils.mv(song.full_path, new_filename)
      FileUtils.touch new_filename, mtime: Time.now.utc + 30.seconds

      @scanner.scan

      # should be able to find the song by the new file's name, and it should have the same rating
      song = Song.active.find_by(full_path: new_filename)

      expect(Song.active.count).to eq(before_song_count)
      expect(song.rating).to eq(new_rating)
    end
  end


end
