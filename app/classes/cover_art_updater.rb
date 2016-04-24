class CoverArtUpdater
  attr_accessor :album

  def initialize(album)
    @album = album
  end

  def update_cover_art
    Rails.logger.debug "Updating cover art cache for album with title: '#{@album.title}'"

    make_cache_directory
    @album.cover_art_cache_file = nil
    @album.cover_art_file = nil

    if @album.songs.any?
      discover_existing_cover_art_file
      discover_existing_cover_art_in_song_metadata
      make_thumbnail_in_cache(size: 300)
      make_thumbnail_in_cache(size: 500)
    end

    @album.save!
  end

  def make_thumbnail_in_cache(size:)
    return if @album.cover_art_cache_file.blank?
    raise "Unsupported thumbnail size" unless [300, 500].include?(size)

    source_file = File.join(Settings.cover_art_cache, @album.cover_art_cache_file)

    output_filename = @album.cover_art_cache_file + "_#{size}"
    destination_file = File.join(Settings.cover_art_cache, output_filename)

    ImageProcessing::send("make_thumbnail_#{size}", source_file, destination_file)

    @album.send("cover_art_file_thumbnail_#{size}=", output_filename)
    @album.save!
  end

  def discover_existing_cover_art_file
    first_song = @album.songs.first
    song_directory = File.dirname(first_song.full_path)

    # check for existing cover art image files that exist in
    # the same location as a song in this album
    Album::COVER_ART_FILENAMES.each do |cover_art_filename|
      file = File.join(song_directory, cover_art_filename)

      Rails.logger.debug "Checking if cover art file exists: #{file}"
      if File.exists?(file)
        Rails.logger.debug "Cover art file exists: #{file}"
        @album.cover_art_file = file

        md5 = Digest::MD5.hexdigest(File.read(file)) + File.extname(file)
        cache_location = File.join(Settings.cover_art_cache, md5)

        FileUtils.copy(file, cache_location)

        image_size = ImageMetadata::image_size(cache_location)
        @album.cover_art_width = image_size[:width]
        @album.cover_art_height = image_size[:height]

        @album.cover_art_cache_file = md5
        @album.save!

        break
      end
    end
  end

  def discover_existing_cover_art_in_song_metadata
    if @album.cover_art_cache_file.blank?
      first_song = @album.songs.first
      extractor = EmbeddedArtExtractor.new(first_song.full_path)
      cache_location = extractor.write_to_cache!

      if cache_location
        @album.cover_art_cache_file = cache_location

        full_art_path = File.join(Settings.cover_art_cache, cache_location)
        image_size = ImageMetadata::image_size(full_art_path)
        @album.cover_art_width = image_size[:width]
        @album.cover_art_height = image_size[:height]

        @album.save!
      end
    end
  end

  private

  def make_cache_directory
    unless File.directory?(Settings.cover_art_cache)
      FileUtils.mkdir_p(Settings.cover_art_cache)
    end
  end

end
