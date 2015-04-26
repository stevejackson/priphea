require 'spec_helper'

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

      expect(File.exists?(album.cover_art_cache_file)).to be true
    end
  end

end
