class Scanner
  attr_accessor :library_path
  attr_accessor :files
  attr_accessor :file_queue

  def initialize(library_path)
    @library_path = library_path
  end

  def gather_files_to_scan(path)
    if path.nil?
      matcher = File.join(@library_path, "**", "*")
    else
      matcher = File.join(path, "**", "*")
    end

    @files = Dir.glob(matcher).select { |f| File.file? f }
  end

  def create_file_queue
    @file_queue = Queue.new

    @files.each do |f|
      @file_queue.push(f)
    end
  end

  def process_file_queue(deep_scan)
    threads = []

    # create a queue pool to process all files
    until file_queue.empty?
      Rails.logger.info "File queue length: #{file_queue.length}"

      file = file_queue.pop(true) rescue nil

      import_song_to_database(file, deep_scan) if file && is_supported_audio_format?(file)
    end

    threads.each { |t| t.join } # don't proceed until all threads are complete
  end

  def update_entire_cover_art_cache
    Album.all.each do |album|
      unless album.has_cover_art?
        album.update_cover_art_cache
      end
    end
  end

  def scan(deep_scan=false, path: nil)
    gather_files_to_scan(path)
    create_file_queue
    process_file_queue(deep_scan)
    update_entire_cover_art_cache
  end

  def is_supported_audio_format?(filename)
    supported = %w(.flac .FLAC .mp3 .MP3)
    supported.include?(File.extname(filename))
  end

  def import_song_to_database(filename, deep_scan=false)
    Rails.logger.debug "Importing file to database: #{filename}"
    song = Song.build_from_file(filename, deep_scan)
    song.save!
    song
  end
end
