require 'spec_helper'

describe SongScanner, file_cleaning: :full do
  describe ".file_is_missing" do
    it "should mark song as missing if file no longer exists" do
      path = "abc/123.mp3"
      create(:active_song, full_path: path)

      song_scanner = SongScanner.new(path, false)
      expect {
        song_scanner.file_is_missing?
      }.to change { song_scanner.song.state }.from("active").to("missing")
    end
  end

  describe ".song_is_unmodified" do
    it "should detect if song is unmodified" do
      full_path = File.join(Settings.library_path, "mp3-test.mp3")

      actual_file_mtime = Time.now.utc

      FileUtils.touch full_path, mtime: actual_file_mtime

      song = create(:song, full_path: full_path)
      song.file_date_modified = actual_file_mtime
      song.save!

      song_scanner = SongScanner.new(full_path, false)

      expect(song_scanner.song_is_unmodified?).to be_truthy
    end

    it "should detect if song is modified" do
      full_path = File.join(Settings.library_path, "mp3-test.mp3")
      song_scanner = SongScanner.new(full_path, false)

      actual_file_mtime = Time.now.utc

      FileUtils.touch full_path, mtime: actual_file_mtime

      song = create(:song, full_path: full_path)
      song.file_date_modified = actual_file_mtime + 30.seconds
      song.save!

      expect(song_scanner.song_is_unmodified?).to be_falsey
    end
  end
end
