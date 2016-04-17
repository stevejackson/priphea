class AudioMetadata
  def self.file_extension(filename)
    File.extname(filename).downcase
  end

  def self.from_file(filename)
    file_extension = AudioMetadata::file_extension(filename)

    extractor = case file_extension
      when ".mp3"
        MetadataExtractors::Mp3MetadataExtractor.new(filename)
      when ".flac"
        MetadataExtractors::FlacMetadataExtractor.new(filename)
      else
        raise "Unsupported file type"
   end

    metadata = extractor.create_metadata_hash
    metadata
  end


  def self.copy_embedded_art_to_cache(filename)
    random_string = Random.rand(2000000).to_s

    full_path_jpg = File.join("/", "tmp", "#{random_string}.jpg")
    full_path_png = File.join("/", "tmp", "#{random_string}.png")

    # extract art to a file in "/tmp"
    file_format = File.extname(filename).downcase
    if file_format == '.flac'
      TagLib::FLAC::File.open(filename) do |file|
        if file.picture_list.length > 0
          picture = file.picture_list.first

          if picture.mime_type == 'image/jpeg'
            AudioMetadata::write_image_to_file!(picture.data, full_path_jpg)
          elsif picture.mime_type == 'image/png'
            AudioMetadata::write_image_to_file!(picture.data, full_path_png)
          end
        end
      end
    elsif file_format == '.mp3'
      TagLib::MPEG::File.open(filename) do |file|
        tag = file.id3v2_tag

        if tag && tag.frame_list('APIC').length > 0
          cover = tag.frame_list('APIC').first

          if cover.mime_type == 'image/jpeg'
            AudioMetadata::write_image_to_file!(cover.picture, full_path_jpg)
          elsif cover.mime_type == 'image/png'
            AudioMetadata::write_image_to_file!(cover.picture, full_path_png)
          end
        end
      end
    end

    # now copy the /tmp file to the cover art cache and return it
    if File.exists?(full_path_jpg)
      Rails.logger.info "Successfully copied embedded JPG art."
      md5 = Digest::MD5.hexdigest(File.read(full_path_jpg)) + File.extname(full_path_jpg)

      destination = File.join(Settings.cover_art_cache, md5)
      FileUtils.copy(full_path_jpg, destination)

      return File.basename(destination)
    elsif File.exists?(full_path_png)
      Rails.logger.info "Successfully copied embedded PNG art."
      md5 = Digest::MD5.hexdigest(File.read(full_path_png)) + File.extname(full_path_png)

      destination = File.join(Settings.cover_art_cache, md5)
      FileUtils.copy(full_path_png, destination)

      return File.basename(destination)
    else
      Rails.logger.info "Failed to find or copy embedded art."
      nil
    end
  end

  def self.write_image_to_file!(cover_art_data, filename)
    File.open(filename, 'wb') do |file|
      file.write(cover_art_data)
    end
  end

  def self.write_cover_art_to_metadata!(filename, cover_art_data, cover_art_file_type)
    file_format = File.extname(filename).downcase
    mime_type = if cover_art_file_type == '.jpg'
      "image/jpeg"
    elsif cover_art_file_type == ".png"
      "image/png"
    end

    if file_format == '.flac'
      Rails.logger.info "--- Writing FLAC metadata."

      TagLib::FLAC::File.open(filename) do |file|
        file.remove_pictures # remove all pre-existing pictures.

        pic = TagLib::FLAC::Picture.new
        pic.type = TagLib::FLAC::Picture::FrontCover
        pic.mime_type = mime_type
        pic.description = "Cover"
        pic.data = cover_art_data

        file.add_picture(pic)
        file.save
      end
    elsif file_format == '.mp3'
      Rails.logger.info "--- Writing MP3 metadata."

      TagLib::MPEG::File.open(filename) do |file|
        tag = file.id3v2_tag

        # Remove pre-existing art
        tag.frame_list('APIC').each do |frame|
          tag.remove_frame(frame)
        end

        file.save

        # Add attached picture frame
        apic = TagLib::ID3v2::AttachedPictureFrame.new
        apic.mime_type = mime_type
        apic.description = "Cover"
        apic.type = TagLib::ID3v2::AttachedPictureFrame::FrontCover
        apic.picture = cover_art_data

        tag.add_frame(apic)

        file.save
      end
    end
  end

  def self.generate_priphea_id_comment(existing_comment, song)
    result = existing_comment || ""
    result.gsub!(/\[PRIPHEA-ID-(.{24})\]/, '')
    result << "[PRIPHEA-ID-#{song.id}]"
    result
  end

  def self.extract_priphea_id_from_comment(existing_comment)
    return nil unless existing_comment.present?

    existing_comment.match /\[PRIPHEA-ID-(.{24})\]/
    $1
  end

  # supported fields for writing:
  # - title
  # - artist
  # - album_artist
  # - track number
  # - disc number
  # - comment
  # - album_title
  def self.write_tag(filename, tag_name, data)
    return false unless Song::WRITABLE_FIELDS.include? tag_name
    file_extension = AudioMetadata::file_extension(filename)

    tag_name = AudioMetadata::rename_tag_from_priphea_to_metadata_name(tag_name, file_extension)

    if %w(.mp3).include?(file_extension)
      TagLib::MPEG::File.open(filename) do |file|
        tag = file.id3v2_tag(true)
        case tag_name
          when 'comment'
            new_frame = true
            if (frame = tag.frame_list('COMM').try(:first))
              new_frame = false
            end
            frame ||= TagLib::ID3v2::CommentsFrame.new
            frame.language = 'eng'
            frame.text = data.to_s
            frame.text_encoding = TagLib::String::UTF8
            tag.add_frame(frame) if new_frame
          when 'TPOS' # part of set / disc #
            new_frame = true
            if (frame = tag.frame_list('TPOS').try(:first))
              new_frame = false
            end
            frame ||= TagLib::ID3v2::TextIdentificationFrame.new("TPOS", TagLib::String::UTF8)
            frame.text = data.to_s
            tag.add_frame(frame) if new_frame
          when 'TPE2'
            new_frame = true
            if (frame = tag.frame_list('TPE2').try(:first))
              new_frame = false
            end
            frame ||= TagLib::ID3v2::TextIdentificationFrame.new("TPE2", TagLib::String::UTF8)
            frame.text = data.to_s
            tag.add_frame(frame) if new_frame
          else
            tag.send(tag_name + "=", data)
        end
        file.save
      end
    elsif %w(.flac).include?(file_extension)
      TagLib::FLAC::File.open(filename) do |file|
        tag = file.xiph_comment
        if %w{album artist comment genre title track year}.include?(tag_name)
          tag.send(tag_name + "=", data.to_s)
        else
          tag.send(:add_field, tag_name, data.to_s)
        end
        file.save
      end
    end
  end

  # if track number is stored in priphea db as "track_number", in mp3 id3v2 it's named "track".
  # this method turns "track_number" into "track".

  # some example of an id3v2 data set:
  # - ["TIT2 Sea-Cat Walkway [Boy Meets Girl]", "TPE1 arc", "TRCK 1/0", "TALB Sea-Cat Walkway - Mother Arrange+Original Album", "TPOS 0/0", "TDRC 2006", "TCON 同ﾺ", "APIC [image/jpeg]", "POPM no@email rating=255 counter=0", "TBPM 0", "TCMP 0", "TDOR 0000", "TPE2 arc", "UFID ", "USLT "]
  def self::rename_tag_from_priphea_to_metadata_name(priphea_tag_name, extension)
    if extension == '.mp3'
      case priphea_tag_name
        when 'track_number'
          'track'
        when 'disc_number'
          'TPOS' # part of set frame
        when 'album_artist'
          'TPE2'
        when 'album_title'
          'album'
        else
          priphea_tag_name
      end
    else
      case priphea_tag_name
        when 'album_title'
          'album'
        else
          priphea_tag_name
      end
    end
  end

end
