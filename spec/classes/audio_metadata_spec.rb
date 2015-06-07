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
      file = File.join("spec", "data", "metadata-test.mp3")

      @song = Song.build_from_file(file)
      @song.save!

      scanner = Scanner.new(Settings.library_path)
      scanner.scan
    end

    it "should be able to read metadata MP3" do
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
      comment = "test_comment"
      filesize = "1572611"
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
      expect(@song.filesize).to eq(filesize)
      expect(@song.filetype).to eq(filetype)
    end
  end

  describe "can read metadata from FLAC" do
    before :each do
      file = File.join("spec", "data", "metadata-test.flac")

      @song = Song.build_from_file(file)
      @song.save!

      scanner = Scanner.new(Settings.library_path)
      scanner.scan
    end

    it "should be able to read metadata FLAC" do
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
      comment = "test_comment"
      filesize = "9413714"
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
      expect(@song.filesize).to eq(filesize)
      expect(@song.filetype).to eq(filetype)
    end
  end
end
