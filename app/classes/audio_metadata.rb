class AudioMetadata
  def self.from_file(filename)
    song = MiniExiftool.new(filename)
    file_extension = File.extname(filename)

    metadata = {}

    if %w(.mp3 .MP3).include?(file_extension)
      metadata['track_number'] = AudioMetadata::mp3_track_number(song.track.to_s)
      metadata['disc_number'] = AudioMetadata::mp3_disc_number(song.part_of_set.to_s)
    elsif %w(.flac .FLAC).include?(file_extension)
      metadata['track_number'] = song.track_number
      metadata['disc_number'] = song.disc
    end

    # same for both FLAC and MP3
    metadata['title'] = song.title
    metadata['artist'] = song.artist
    metadata['album'] = song.album

    metadata
  end

  # mp3's track number metadata is sometimes in format like: 3/0
  # convert this to 3
  def self.mp3_track_number(track_number_string)
    if (index = track_number_string.index('/'))
      track_number_string[0, index]
    else
      track_number_string
    end
  end

  # disc number (part of set) sometims format like: 1/2
  # convert this to 1
  def self.mp3_disc_number(disc_number_string)
    if disc_number_string && (index = disc_number_string.index('/'))
      disc_number_string[0, index]
    else
      disc_number_string
    end
  end
end
