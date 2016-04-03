require 'rails_helper'

describe AudioMetadata do
  describe "duration" do
    it "should work for format 1:02:43" do
      input = "1:02:43"

      result = AudioMetadata::mp3_duration(input)

      expect(result).to eq("1:02:43")
    end

    it "should work for format 0:02:43" do
      input = "0:02:43"

      result = AudioMetadata::mp3_duration(input)

      expect(result).to eq("02:43")
    end

    it "should work for format 42.01 s" do
      input = "42.01 s"

      result = AudioMetadata::mp3_duration(input)

      expect(result).to eq("00:42")
    end
  end

  describe "total discs" do
    it "should be able to work for MP3 total disc format 2/3" do
      input = "2/3"
      result = AudioMetadata::mp3_total_discs(input)

      expect(result).to eq("3")
    end
  end

  describe "total tracks" do
    it "should be able to work for MP3 total track format 1/33" do
      input = "1/33"
      result = AudioMetadata::mp3_total_tracks(input)

      expect(result).to eq("33")
    end
  end

  describe "can read metadata from MP3" do
    before :each do
      file = File.join("spec", "data", "test_songs", "metadata-test.mp3")

      @song = Song.build_from_file(file)
      @song.save!

      scanner = Scanner.new(Settings.library_path)
      scanner.scan
    end

    it "should be able to read metadata MP3" do
      ext = ".mp3"

      year = "1998"
      title = "Main Theme"
      track_number = 1
      total_tracks = 33
      disc_number = 1
      total_discs = 1
      genre = "Soundtrack"
      album_artist = "Album_artist"
      artist = "Michael"
      composer = "Michael Hoenig"
      comment = "[PRIPHEA-ID-#{@song.id}]"
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

  describe "can read metadata from FLAC" do
    before :each do
      file = File.join("spec", "data", "test_songs", "metadata-test.flac")

      @song = Song.build_from_file(file)
      @song.save!

      scanner = Scanner.new(Settings.library_path)
      scanner.scan
    end

    it "should be able to read metadata FLAC" do
      ext = ".flac"

      year = "1998"
      title = "Main Theme"
      track_number = 1
      total_tracks = 33
      disc_number = 1
      total_discs = 1
      genre = "Soundtrack"
      album_artist = "Album_artist"
      artist = "Michael"
      composer = "Michael Hoenig"
      comment = "[PRIPHEA-ID-#{@song.id}]"
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

      @song = Song.build_from_file(file)
      @song.save!

      scanner = Scanner.new(Settings.library_path)
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
    describe "individual metadata fields" do
      before :each do
        @files = [
          File.join(Settings.library_path, "embedded-art.flac"),
          File.join(Settings.library_path, "test_rescan.mp3")
        ]

        @scanner = Scanner.new(Settings.library_path)
        @scanner.scan
      end

      it "should be able to write a short comment" do
        @files.each do |file|
          short_string = "short"
          AudioMetadata::write_tag(file, "comment", short_string)

          actual_metadata_comment = AudioMetadata::from_file(file)['comment']
          expect(actual_metadata_comment).to eq(short_string)
        end
      end

      it "should be able to write long comment" do
        @files.each do |file|
          long_string = "[BLAH-BLAH-8043782047u2fjeauf892u89rhfe89]"
          AudioMetadata::write_tag(file, "comment", long_string)

          actual_metadata_comment = AudioMetadata::from_file(file)['comment']
          expect(actual_metadata_comment).to eq(long_string)
        end
      end
    end

    describe "Writing a song's data to metadata" do
      before :each do
        @files = [
            File.join(Settings.library_path, "embedded-art.flac"),
            File.join(Settings.library_path, "test_rescan.mp3")
        ]

        @scanner = Scanner.new(Settings.library_path)
        @scanner.scan
      end

      it "can update a file's metadata with info from Priphea song database" do
        @files.each do |file|
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
    end

  end

  describe "rename_tag_from_priphea_to_metadata_name" do
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
