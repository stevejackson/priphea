require 'spec_helper'

describe SongScanner do
  context ".file_is_missing" do
    it "should mark song as missing if file no longer exists" do
      path = "abc/123.mp3"
      create(:active_song, full_path: path)

      song_scanner = SongScanner.new(path, false)
      expect {
        song_scanner.file_is_missing?
      }.to change { song_scanner.song.state }.from("active").to("missing")
    end
  end
end
