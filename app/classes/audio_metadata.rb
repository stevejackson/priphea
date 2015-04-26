class AudioMetadata
  def self.from_file(filename)
    song = MiniExiftool.new(filename)
    song
  end
end
