require 'rails_helper'

describe MetadataExtractors::Mp3MetadataExtractor do

  context "Unit tests" do
    before :each do
      @extractor = MetadataExtractors::Mp3MetadataExtractor.new("spec/data/test_songs/metadata-test.mp3")
      @extractor.file_metadata = nil
    end

    context ".duration" do
      it "works for format: 0:02:43" do
        @extractor.file_metadata = double(duration: "0:02:43")
        expect(@extractor.duration).to eq("02:43")
      end

      it "works for format: 1:02:43" do
        @extractor.file_metadata = double(duration: "1:02:43")
        expect(@extractor.duration).to eq("1:02:43")
      end

      it "works for format: 42.01 s" do
        @extractor.file_metadata = double(duration: "42.01 s")
        expect(@extractor.duration).to eq("00:42")
      end
    end

    context ".total_discs" do
      it "should work for format: 2/3" do
        @extractor.file_metadata = double(part_of_set: "2/3")
        expect(@extractor.total_discs).to eq("3")
      end
    end

    context ".total_tracks" do
      it "should work for format: 1/33" do
        @extractor.file_metadata = double(track: "1/33")
        expect(@extractor.total_tracks).to eq("33")
      end
    end
  end

  context "reading data from a real .mp3 file" do
    before :each do
      file = File.join("spec", "data", "test_songs", "metadata-test.mp3")
      @extractor = MetadataExtractors::Mp3MetadataExtractor.new(file)
    end

    it "should be able to read metadata MP3" do
      year = "2000"
      title = "Test song"
      track_number = 1
      total_tracks = "12"
      disc_number = 1
      total_discs = '2'
      genre = "Soul"
      album_artist = "Test album artist"
      artist = "Test artist"
      composer = "Test composer"
      comment = "Test comment"
      filetype = ".mp3"

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
