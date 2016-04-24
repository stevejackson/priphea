require 'spec_helper'

describe EmbeddedArtExtractor do
  describe ".extract_cover_art_from_metadata" do
    it "can extract cover art data from a FLAC file" do
      file = "spec/data/test_songs/embedded-art.flac"
      extractor = EmbeddedArtExtractor.new(file)

      mime_type, data = extractor.extract_cover_art_from_metadata

      expect(mime_type).to eq("image/jpeg")
      expect(data).to_not be_nil
    end

    it "can extract cover art data from a MP3 file" do
      file = "spec/data/test_songs/embedded-art.mp3"
      extractor = EmbeddedArtExtractor.new(file)

      mime_type, data = extractor.extract_cover_art_from_metadata

      expect(mime_type).to eq("image/png")
      expect(data).to_not be_nil
    end
  end
end
