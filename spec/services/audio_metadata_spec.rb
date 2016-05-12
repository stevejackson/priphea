require 'rails_helper'

describe AudioMetadata, file_cleaning: :full do
  describe "can read metadata from MP3" do
    before :each do
      file = File.join("spec", "data", "test_songs", "metadata-test.mp3")

      @song = Song.build_song_from_file(file)
      @song.save!

      scanner = LibraryScanner.new(Settings.library_path)
      scanner.scan
    end

    it "should be able to read metadata MP3 into Song record" do
      year = "2000"
      title = "Test song"
      track_number = 1
      total_tracks = 12
      disc_number = 1
      total_discs = 2
      genre = "Soul"
      album_artist = "Test album artist"
      artist = "Test artist"
      composer = "Test composer"
      comment = "Test comment[PRIPHEA-ID-#{@song.id}]"
      filetype = ".mp3"

      expect(@song.year).to eq(year)
      expect(@song.title).to eq(title)
      expect(@song.track_number).to eq(track_number)
      expect(@song.total_tracks).to eq(total_tracks)
      expect(@song.disc_number).to eq(disc_number)
      expect(@song.total_discs).to eq(total_discs)
      expect(@song.genre).to eq(genre)
      expect(@song.album_artist).to eq(album_artist)
      expect(@song.artist).to eq(artist)
      expect(@song.composer).to eq(composer)
      expect(@song.comment).to eq(comment)
      expect(@song.filetype).to eq(filetype)
    end
  end

  describe "can read metadata from FLAC into Song record" do
    before :each do
      file = File.join("spec", "data", "test_songs", "metadata-test.flac")

      @song = Song.build_song_from_file(file)
      @song.save!

      scanner = LibraryScanner.new(Settings.library_path)
      scanner.scan
    end

    it "should be able to read metadata FLAC" do
      year = "2000"
      title = "Test song"
      track_number = 1
      total_tracks = 12
      disc_number = 1
      total_discs = 2
      genre = "Soul"
      album_artist = "Test album artist"
      artist = "Test artist"
      composer = "Test composer"
      comment = "Test comment[PRIPHEA-ID-#{@song.id}]"
      filetype = ".flac"

      expect(@song.year).to eq(year)
      expect(@song.title).to eq(title)
      expect(@song.track_number).to eq(track_number)
      expect(@song.total_tracks).to eq(total_tracks)
      expect(@song.disc_number).to eq(disc_number)
      expect(@song.total_discs).to eq(total_discs)
      expect(@song.genre).to eq(genre)
      expect(@song.album_artist).to eq(album_artist)
      expect(@song.artist).to eq(artist)
      expect(@song.composer).to eq(composer)
      expect(@song.comment).to eq(comment)
      expect(@song.filetype).to eq(filetype)
    end
  end

  describe "can generate priphea song ID for comment" do
    before :each do
      file = File.join("spec", "data", "test_songs", "metadata-test.flac")

      @song = Song.build_song_from_file(file)
      @song.save!

      scanner = LibraryScanner.new(Settings.library_path)
      scanner.scan
    end

    it "can generate the comment correctly given an empty comment" do
      existing_comment = ""
      expected_comment = "[PRIPHEA-ID-#{@song.id}]"

      result = AudioMetadata.generate_priphea_id_comment(existing_comment, @song)

      expect(expected_comment).to eq(result)
    end

    it "can generate the comment correctly given an existing comment" do
      existing_comment = "Blah blah downloaded at somewhere.com"
      expected_comment = "Blah blah downloaded at somewhere.com[PRIPHEA-ID-#{@song.id}]"

      result = AudioMetadata.generate_priphea_id_comment(existing_comment, @song)

      expect(expected_comment).to eq(result)
    end

    it "can generate the comment correctly given an existing comment and existing priphea ID" do
      existing_comment = "Blah blah downloaded at somewhere.com [PRIPHEA-ID-5658797a5374650f8f470000] more"
      expected_comment = "Blah blah downloaded at somewhere.com  more[PRIPHEA-ID-#{@song.id}]"

      result = AudioMetadata.generate_priphea_id_comment(existing_comment, @song)

      expect(expected_comment).to eq(result)
    end

    it "can extract song ID of a comment" do
      existing_comment = "Blah blah downloaded at somewhere.com [PRIPHEA-ID-5658797a5374650f8f470000] more"
      expected_id = "5658797a5374650f8f470000"

      result = AudioMetadata.extract_priphea_id_from_comment(existing_comment)

      expect(expected_id).to eq(result)
    end
  end

  describe "writing tags" do
    shared_examples_for "writable_metadata_fields" do
      before :each do
        @scanner = LibraryScanner.new(Settings.library_path)
        @scanner.scan
      end

      it "should be able to write a short comment" do
        short_string = "short"
        AudioMetadata::write_tag(file, "comment", short_string)

        actual_metadata_comment = AudioMetadata::from_file(file)['comment']
        expect(actual_metadata_comment).to eq(short_string)
      end

      it "should be able to write long comment" do
        long_string = "[BLAH-BLAH-8043782047u2fjeauf892u89rhfe89]"
        AudioMetadata::write_tag(file, "comment", long_string)

        actual_metadata_comment = AudioMetadata::from_file(file)['comment']
        expect(actual_metadata_comment).to eq(long_string)
      end

      it "can update a file's metadata with info from Priphea song database" do
        @song = Song.find_by(full_path: file)

        new_comment = 'Abcde'
        new_title = 'Weird title'
        new_track_number = 44
        new_disc_number = 33
        new_artist = "Hanky John"
        new_album_artist = "Kaboom"
        new_album_title = "Album title hey"

        @song.comment = new_comment
        @song.title = new_title
        @song.track_number = new_track_number
        @song.disc_number = new_disc_number
        @song.artist = new_artist
        @song.album_artist = new_album_artist
        @song.album_title = new_album_title

        expect(@song.write_metadata_to_file!).to be_truthy

        metadata = AudioMetadata::from_file(@song.full_path)
        expect(metadata['title']).to eq(new_title)
        expect(metadata['comment']).to eq(new_comment)
        expect(metadata['track_number']).to eq(new_track_number)
        expect(metadata['disc_number']).to eq(new_disc_number)
        expect(metadata['artist']).to eq(new_artist)
        expect(metadata['album_artist']).to eq(new_album_artist)
        expect(metadata['album']).to eq(new_album_title)
      end
    end

    describe ".mp3" do
      it_behaves_like "writable_metadata_fields" do
        let!(:file) { File.join(Settings.library_path, "mp3-test.mp3") }
      end
    end

    describe ".flac" do
      it_behaves_like "writable_metadata_fields" do
        let!(:file) { File.join(Settings.library_path, "flac-test.flac") }
      end
    end
  end

  describe ".rename_tag_from_priphea_to_metadata_name" do
    it "handles same-name case" do
      result = AudioMetadata::rename_tag_from_priphea_to_metadata_name("comment", @ext)
      expect(result).to eq("comment")
    end

    context "MP3" do
      before { @ext = ".mp3" }

      it "track_number" do
        result = AudioMetadata::rename_tag_from_priphea_to_metadata_name("track_number", @ext)
        expect(result).to eq("track")
      end

      it "disc_number" do
        result = AudioMetadata::rename_tag_from_priphea_to_metadata_name("disc_number", @ext)
        expect(result).to eq("TPOS")
      end

      it "album_artist" do
        result = AudioMetadata::rename_tag_from_priphea_to_metadata_name("album_artist", @ext)
        expect(result).to eq("TPE2")
      end
    end

    context "FLAC" do
      before { @ext = ".flac" }
    end
  end
end
