class EmbeddedArtExtractor
  attr_accessor :filename

  def initialize(filename)
    @filename = filename
  end

  def write_to_cache!
    temporary_file = extract_picture_data_to_tmp_file
    write_cover_art_to_cache(temporary_file)
  end

  def write_cover_art_to_cache(temporary_file)
    # now copy the /tmp file to the cover art cache and return it
    if File.exist?(temporary_file)
      md5 = Digest::MD5.hexdigest(File.read(temporary_file)) + File.extname(temporary_file)
      destination = File.join(Settings.cover_art_cache, md5)
      FileUtils.copy(temporary_file, destination)

      return File.basename(destination)
    else
      Rails.logger.info "Failed to find or copy embedded art."
      nil
    end
  end

  def extract_picture_data_to_tmp_file
    random_string = Random.rand(2000000).to_s
    full_path_jpg = File.join("/", "tmp", "#{random_string}.jpg")
    full_path_png = File.join("/", "tmp", "#{random_string}.png")

    mime_type, picture_data = extract_cover_art_from_metadata

    case mime_type
    when 'image/jpeg'
      write_image_to_file!(picture_data, full_path_jpg)
      return full_path_jpg
    when 'image/png'
      write_image_to_file!(picture_data, full_path_png)
      return full_path_png
    end
  end

  def extract_cover_art_from_metadata
    file_format = File.extname(@filename).downcase

    if file_format == '.flac'
      TagLib::FLAC::File.open(@filename) do |file|
        if file.picture_list.length > 0
          picture = file.picture_list.first
          return [picture.mime_type, picture.data]
        end
      end
    elsif file_format == '.mp3'
      TagLib::MPEG::File.open(@filename) do |file|
        tag = file.id3v2_tag

        if tag && tag.frame_list('APIC').length > 0
          cover = tag.frame_list('APIC').first

          return [cover.mime_type, cover.picture]
        end
      end
    else
      raise "Unsupported MIME type in this song file"
    end
  end

  def write_image_to_file!(cover_art_data, filename)
    File.open(filename, 'wb') do |file|
      file.write(cover_art_data)
    end
  end
end
