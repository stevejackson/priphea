class CoverArtUpdater
  attr_accessor :album

  def initialize(album)
    @album = album
  end

  def update_cover_art
    Rails.logger.debug "---- "
    Rails.logger.debug "Updating cover art cache for: #{@album.inspect}"
    make_cache_directory
    @album.cover_art_cache_file = nil
    @album.cover_art_file = nil

    if @album.songs.any?
      discover_existing_cover_art_file

      # if cover art file does not exist, we should also check a song in this
      # album for embedded art.
      if @album.cover_art_cache_file.blank?
        song = @album.songs.first
        Rails.logger.info "Trying to extract embedded art from: #{song.inspect}"

        extractor = EmbeddedArtExtractor.new(song.full_path)
        cache_location = extractor.write_to_cache!
        Rails.logger.info "Cache location: #{cache_location}"

        if cache_location
          @album.cover_art_cache_file = cache_location

          full_art_path = File.join(Settings.cover_art_cache, cache_location)
          image_size = ImageMetadata::image_size(full_art_path)
          @album.cover_art_width = image_size[:width]
          @album.cover_art_height = image_size[:height]

          @album.save!
        end
      end

      # make thumbnail cache version, 500px
      unless @album.cover_art_cache_file.blank?
        Rails.logger.info "Trying to make a 500px thumbnail version of album art."

        output_filename = @album.cover_art_cache_file + "_500"
        Rails.logger.info "Outputting to file: #{output_filename}"

        ImageProcessing::make_thumbnail_500(
          File.join(Settings.cover_art_cache, @album.cover_art_cache_file),
          File.join(Settings.cover_art_cache, output_filename)
        )

        @album.cover_art_file_thumbnail_500 = output_filename
        @album.save!
      end

      # make thumbnail cache version, 500px
      unless @album.cover_art_cache_file.blank?
        Rails.logger.info "Trying to make a 300px thumbnail version of album art."

        output_filename = @album.cover_art_cache_file + "_300"
        Rails.logger.info "Outputting to file: #{output_filename}"

        ImageProcessing::make_thumbnail_300(
          File.join(Settings.cover_art_cache, @album.cover_art_cache_file),
          File.join(Settings.cover_art_cache, output_filename)
        )

        @album.cover_art_file_thumbnail_300 = output_filename
        @album.save!
      end
    end

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

  private

  def make_cache_directory
    unless File.directory?(Settings.cover_art_cache)
      FileUtils.mkdir_p(Settings.cover_art_cache)
    end
  end

end
