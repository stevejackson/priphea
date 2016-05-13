require 'rails_helper'

describe FlacMetadataWriter do
  describe ".rename_tag_from_priphea_to_metadata_name" do
    let!(:writer) { FlacMetadataWriter.new("filename.flac") }

    it "handles same-name case" do
      result = writer.rename_tag_from_priphea_to_metadata_name("comment")
      expect(result).to eq("comment")
    end

    it "renames album title" do
      result = writer.rename_tag_from_priphea_to_metadata_name("album_title")
      expect(result).to eq("album")
    end
  end
end
