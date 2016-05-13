require 'rails_helper'

describe MetadataWriters::Mp3MetadataWriter do
  describe ".rename_tag_from_priphea_to_metadata_name" do
    let!(:writer) { Mp3MetadataWriter.new("filename.mp3") }

    it "handles same-name case" do
      result = writer.rename_tag_from_priphea_to_metadata_name("comment")
      expect(result).to eq("comment")
    end

    it "track_number" do
      result = writer.rename_tag_from_priphea_to_metadata_name("track_number")
      expect(result).to eq("track")
    end

    it "disc_number" do
      result = writer.rename_tag_from_priphea_to_metadata_name("disc_number")
      expect(result).to eq("TPOS")
    end

    it "album_artist" do
      result = writer.rename_tag_from_priphea_to_metadata_name("album_artist")
      expect(result).to eq("TPE2")
    end
  end
end
