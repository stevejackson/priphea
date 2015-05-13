class Scanner
  attr_accessor :library_path

  def initialize(library_path)
    @library_path = library_path
  end

  def scan
    matcher = File.join(@library_path, "**", "*")
    files =  Dir.glob(matcher).select { |f| File.file? f }

    file_queue = Queue.new
    files.each do |f|
      file_queue.push(f)
    end

    threads = []

    # create a queue pool to process all files
    Settings.scanning_threads.times do
      threads << Thread.new do
        until file_queue.empty?
          Rails.logger.info "File queue length: #{file_queue.length}"

          file = file_queue.pop(true) rescue nil

          if file && is_supported_audio_format?(file)
            import_song_to_database(file)
          end
        end
      end
    end

    threads.each { |t| t.join } # don't proceed until all threads are complete

    Album.all.each do |album|
      album.update_cover_art_cache
    end
  end

  def is_supported_audio_format?(filename)
    supported = %w(.flac .FLAC .mp3 .MP3)
    supported.include?(File.extname(filename))
  end

  def import_song_to_database(filename)
    song = Song.build_from_file(filename)
    song.save!
  end
end
