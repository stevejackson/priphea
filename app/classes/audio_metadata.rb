require 'taglib'

class AudioMetadata

  UNWRITABLE_FIELDS = %w{
    duration
    year
    total_tracks
    total_discs
    genre
    composer
    filesize
    filetype
  }

  def self.file_extension(filename)
    File.extname(filename).downcase
  end

  def self.from_file(filename)
    song = MiniExiftool.new(filename)
    file_extension = AudioMetadata::file_extension(filename)
    metadata = {}

    if %w(.mp3).include?(file_extension)
      metadata['track_number'] = AudioMetadata::mp3_track_number(song.track.to_s)
      metadata['total_tracks'] = AudioMetadata::mp3_total_tracks(song.track.to_s)
      metadata['disc_number'] = AudioMetadata::mp3_disc_number(song.part_of_set.to_s)
      metadata['total_discs'] = AudioMetadata::mp3_total_discs(song.part_of_set.to_s)
      metadata['duration'] = AudioMetadata::mp3_duration(song.duration.to_s)

      metadata['album_artist'] = song.band
    elsif %w(.flac).include?(file_extension)
      metadata['track_number'] = song.track_number
      metadata['total_tracks'] = song.total_tracks
      metadata['disc_number'] = AudioMetadata::flac_disc_number(song.disc, song.disc_number)
      metadata['total_discs'] = song.total_discs ? song.total_discs.to_s : nil
      metadata['duration'] = AudioMetadata::mp3_duration(song.duration.to_s)

      metadata['album_artist'] = song.album_artist
    end

    # same for both FLAC and MP3
    metadata['title'] = song.title
    metadata['artist'] = song.artist
    metadata['album'] = song.album
    metadata['year'] = song.year.to_s
    metadata['genre'] = song.genre
    metadata['composer'] = song.composer
    metadata['comment'] = AudioMetadata::comment(song, file_extension)

    metadata['filesize'] = File.size(filename).to_s

    metadata['filetype'] = file_extension

    metadata
  end

  def self.comment(exiftool_song, ext)
    if ext == '.mp3'
      exiftool_song.comment
    elsif ext == '.flac'
      exiftool_song.description
    end
  end

  # mp3's track number metadata is sometimes in format like: 3/0
  # convert this to 3
  def self.mp3_track_number(track_number_string)
    if (index = track_number_string.index('/'))
      track_number_string[0, index].try(:to_i)
    else
      track_number_string.try(:to_i)
    end
  end

  # mp3's track number metadata is sometimes in format like: 1/33
  # convert this to 33
  def self.mp3_total_tracks(track_number_string)
    if (index = track_number_string.index('/'))
      track_number_string[index + 1, track_number_string.length]
    else
      track_number_string
    end
  end

  # disc number (part of set) sometimes formatted like: 1/2
  # convert this to 1
  def self.mp3_disc_number(disc_number_string)
    if disc_number_string && (index = disc_number_string.index('/'))
      disc_number_string[0, index].try(:to_i)
    else
      disc_number_string.try(:to_i)
    end
  end

  # flac sometimes uses `disc` tag, sometimes `disc_number`, sometimes
  # in format 1/2
  # convert this to 1
  def self.flac_disc_number(disc, disc_number)
    disc_number_string = disc_number || disc

    if disc_number_string && disc_number_string.is_a?(String) && (index = disc_number_string.index('/'))
      disc_number_string[0, index]
    else
      disc_number_string
    end
  end

  # flac sometimes uses `disc` tag, sometimes `disc_number`, sometimes
  # in format 1/2
  # convert this to 1
  # def self.flac_total_discs(disc, disc_number)
  #   disc_number_string = disc or disc_number
  #
  #   if disc_number_string && disc_number_string.is_a?(String) && (index = disc_number_string.index('/'))
  #     disc_number_string[index + 1, disc_number_string.length]
  #   else
  #     nil
  #   end
  # end

  def self.mp3_total_discs(disc_number)
    disc_number_string = disc_number

    if disc_number_string && disc_number_string.is_a?(String) && (index = disc_number_string.index('/'))
      disc_number_string[index + 1, disc_number_string.length]
    else
      nil
    end
  end

  # in format like: 0:02:43 (approx)
  def self.mp3_duration(duration)
    # in format like: 0:02:43 (approx)
    if duration.match /(\d{1,2}):(\d{1,2}):(\d{1,2})/
      hours = $1.strip.to_i
      minutes = $2.strip.to_i
      seconds = $3.strip.to_i

      if hours.to_i == 0
        return sprintf("%02d:%02d", minutes, seconds)
      else
        return sprintf("%01s:%02d:%02d", hours, minutes, seconds)
      end
    elsif duration.match /(\d{1,2})\.(\d{1,2}) s/i
      # in format like: 23.41 s (approx)
      # $1 = 23
      # $2 = 41
      seconds = $1.strip.to_i
      return sprintf("%02d:%02d", 0, seconds)
    end
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
    puts "Extracting: #{$1} from #{existing_comment}"
    $1
  end

  # supported fields for writing:
  # - title
  # - artist
  # x album_artist
  # - track number
  # - disc number
  # - comment
  def self.write_tag(filename, tag_name, data)
    return false if UNWRITABLE_FIELDS.include? tag_name
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
        else
          priphea_tag_name
      end
    else
      priphea_tag_name
    end
  end

end
