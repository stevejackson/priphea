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

end
