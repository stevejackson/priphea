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

  context ".write_metadata_to_file" do
    let!(:file) { "arc/Disc 00/02 Empty Taste of Summer On The Beach [Let's Start The Adventure].mp3" }

    it "can reassign song to a different album if the album changed" do
      @scanner = LibraryScanner.new(Settings.library_path)
      @song = Song.find_by(full_path: file)

      previous_album_id = @song.album_id
      next_album = Album.where.not(id: previous_album_id).first

      new_album_artist = "Kaboom"

      @song.album_id = 0 # TODO


      expect(@song.write_metadata_to_file!).to be_truthy

      metadata = AudioMetadata::from_file(@song.full_path)
      expect(metadata['title']).to eq(new_title)
      expect(metadata['comment']).to eq(new_comment)
      expect(metadata['track_number']).to eq(new_track_number)
      expect(metadata['disc_number']).to eq(new_disc_number)
      expect(metadata['artist']).to eq(new_artist)
      expect(metadata['album_artist']).to eq(new_album_artist)
    end
  end


end
