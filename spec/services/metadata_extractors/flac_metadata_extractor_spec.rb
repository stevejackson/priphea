require 'rails_helper'

describe MetadataExtractors::FlacMetadataExtractor do
  before :all do
    path = File.join("spec", "data", "test_songs", "metadata-test.flac")
    @extractor = MetadataExtractors::FlacMetadataExtractor.new(path)
  end

  context "Unit tests" do
    context ".duration" do
      it "works for format: 0:02:43" do
        @extractor.file_metadata.duration = "0:02:43"
        expect(@extractor.duration).to eq("02:43")
      end

      it "works for format: 1:02:43" do
        @extractor.file_metadata.duration = "1:02:43"
        expect(@extractor.duration).to eq("1:02:43")
      end

      it "works for format: 42.01 s" do
        @extractor.file_metadata.duration = "42.01 s"
        expect(@extractor.duration).to eq("00:42")
      end
    end
  end

  context "Test reading a real file" do
    before :each do
      file = File.join("spec", "data", "test_songs", "metadata-test.flac")
      @extractor = MetadataExtractors::FlacMetadataExtractor.new(file)
    end

    it "should be able to read metadata FLAC" do
      year = "1998"
      title = "Main Theme"
      track_number = 1
      total_tracks = 33
      disc_number = 1
      total_discs = "1"
      genre = "Soundtrack"
      album_artist = "Album_artist"
      artist = "Michael"
      composer = "Michael Hoenig"
      comment = nil
      filetype = ".flac"

      expect(@extractor.year).to eq(year)
      expect(@extractor.title).to eq(title)
      expect(@extractor.track_number).to eq(track_number)
      expect(@extractor.total_tracks).to eq(total_tracks)
      expect(@extractor.disc_number).to eq(disc_number)
      expect(@extractor.total_discs).to eq(total_discs)
      expect(@extractor.genre).to eq(genre)
      expect(@extractor.album_artist).to eq(album_artist)
      expect(@extractor.artist).to eq(artist)
      expect(@extractor.composer).to eq(composer)
      expect(@extractor.comment).to eq(comment)
      expect(@extractor.filetype).to eq(filetype)
    end
  end
end
