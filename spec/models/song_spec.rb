require 'rails_helper'

describe Song do

  # validations
  it { should validate_presence_of(:album) }

  context "#write_metadata_to_file" do
    it "can reassign song to a different album if the album changed" do
      pending "Not implemented"
      fail
      @files.each do |file|
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


end
