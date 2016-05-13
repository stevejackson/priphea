require 'rails_helper'

describe Song do

  describe "Validations" do
    it { should validate_presence_of(:album) }
  end

  describe ".create_album_association_from_string" do
    let!(:song) { create(:song) }

    it "should return an album of untitled if nil" do
      song.create_album_association_from_string(nil)
      expect(song.album.title).to eq("Untitled")
    end

    it "should set album of appropriate name" do
      song.create_album_association_from_string("Baldur's Gate")
      expect(song.album.title).to eq("Baldur's Gate")
    end
  end

  describe ".mime_type" do
    it "returns :mp3 for mp3 files" do
      song = create(:song, full_path: "blah.mp3")
      expect(song.mime_type).to eq(:mp3)
    end

    it "returns :flac for flac files" do
      song = create(:song, full_path: "blah.flac")
      expect(song.mime_type).to eq(:flac)
    end

    it "raises exception for other files" do
      song = create(:song, full_path: "test.aac")
      expect{ song.mime_type }.to raise_exception(Song::UnsupportedFileFormatException)
    end
  end

end
