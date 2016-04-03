class Scanner
  attr_accessor :library_path

  def initialize(library_path)
    @library_path = library_path
  end

  def scan(deep_scan=false)
    matcher = File.join(@library_path, "**", "*")
    files =  Dir.glob(matcher).select { |f| File.file? f }

    file_queue = Queue.new
    files.each do |f|
      file_queue.push(f)
    end

    threads = []

    # create a queue pool to process all files
    until file_queue.empty?
      Rails.logger.info "File queue length: #{file_queue.length}"

      file = file_queue.pop(true) rescue nil

      import_song_to_database(file, deep_scan) if file && is_supported_audio_format?(file)
    end

    threads.each { |t| t.join } # don't proceed until all threads are complete

    Album.all.each do |album|
      unless album.has_cover_art?
        album.update_cover_art_cache
      end
    end
  end

  def is_supported_audio_format?(filename)
    supported = %w(.flac .FLAC .mp3 .MP3)
    supported.include?(File.extname(filename))
  end

  def import_song_to_database(filename, deep_scan=false)
    song = Song.build_from_file(filename, deep_scan)
    song.save!
    song
  end
end
