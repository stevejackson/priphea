class Scanner
  attr_accessor :library_path

  def initialize(library_path)
    @library_path = library_path
  end

  def scan
    matcher = File.join(@library_path, "**", "*")
    directories =  Dir.glob(matcher).select { |f| File.directory? f }

    directories.each do |directory|
      # for each folder, examine any audio files.
      audio_files = Dir.entries(directory).select { |f| is_supported_audio_format?(f) }

      audio_files.each do |file|
        full_file_path = File.join(directory, file)

        add_song_to_database(full_file_path)
      end
    end

    # update cover art cache
    Album.all.each do |album|
      album.update_cover_art_cache
    end
  end

  def is_supported_audio_format?(filename)
    supported = %w(.flac .FLAC .mp3 .MP3)
    supported.include?(File.extname(filename))
  end

  def add_song_to_database(filename)
    song = Song.build_from_file(filename)
    song.save!
  end
end
