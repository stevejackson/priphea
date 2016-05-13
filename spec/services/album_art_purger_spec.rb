require 'spec_helper'

describe AlbumArtPurger, file_cleaning: :full do
  describe ".purge_existing_art_files" do
    before do
      @scanner = LibraryScanner.new(Settings.library_path)
      @scanner.scan
    end

    it "should remove existing art files from an album directory" do
      album = Album.where(title: "Rogue Galaxy Premium Arrange").first

      expect {
        AlbumArtPurger.new(album).purge_existing_art_files
      }.to change { File.exist?(album.cover_art_file) }.from(true).to(false)
    end
  end
end
