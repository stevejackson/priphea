require 'spec_helper'

describe SongScanner do
  context ".file_is_missing" do
    it "should mark song as missing if file no longer exists" do
      path = "abc/123.mp3"
      song = create(:active_song, full_path: path)

      expect {
        song_scanner = SongScanner.new(path, false)
        song_scanner.scan_file
      }.to change { song.state }.from("active").to("missing")
    end
  end
end
