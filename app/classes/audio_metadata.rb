require 'taglib'

class AudioMetadata
  def self.from_file(filename)
    song = MiniExiftool.new(filename)
    file_extension = File.extname(filename)

    metadata = {}

    if %w(.mp3 .MP3).include?(file_extension)
      metadata['track_number'] = AudioMetadata::mp3_track_number(song.track.to_s)
      metadata['disc_number'] = AudioMetadata::mp3_disc_number(song.part_of_set.to_s)
      metadata['duration'] = AudioMetadata::mp3_duration(song.duration.to_s)
    elsif %w(.flac .FLAC).include?(file_extension)
      metadata['track_number'] = song.track_number
      metadata['disc_number'] = AudioMetadata::flac_disc_number(song.disc, song.disc_number)
      metadata['duration'] = AudioMetadata::mp3_duration(song.duration.to_s)
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

  # def self.copy_embedded_art_to_cache(filename)
  #   # for now, 4 commands can be run to try and export art. after, we'll check
  #   # if any of the art was extracted by exiftool.
  #
  #   # if so, we'll copy it to the cover art cache and return the filename.
  #
  #   random_string = Random.rand(2000000).to_s
  #
  #   full_path_jpg = File.join("/", "tmp", "#{random_string}.jpg")
  #   full_path_png = File.join("/", "tmp", "#{random_string}.png")
  #
  #   null = ">/dev/null 2>&1"
  #
  #   puts "Trying to copy embedded art to cover art cache with following possible filenames..."
  #   puts "full_path_jpg: #{full_path_jpg}"
  #   puts "full_path_png: #{full_path_png}"
  #
  #   output = system %Q{ exiftool -if '$picturemimetype eq "image/jpeg"' -picture -b -w #{full_path_jpg}%c -ext flac "#{filename}" #{null} }
  #   puts "FLAC image/jpeg: #{output}"
  #   output = system %Q{ exiftool -if '$picturemimetype eq "image/png"' -picture -b -w #{full_path_png}%c -ext flac "#{filename}" #{null} }
  #   puts "FLAC image/png: #{output}"
  #
  #   output = system %Q{ exiftool -if '$picturemimetype eq "image/jpeg"' -picture -b -w #{full_path_jpg}%c -ext mp3 "#{filename}" #{null} }
  #   puts "mp3 image/jpeg: #{output}"
  #   output = system %Q{ exiftool -if '$picturemimetype eq "image/png"' -picture -b -w #{full_path_png}%c -ext mp3 "#{filename}" #{null} }
  #   puts "mp3 image/png: #{output}"
  #
  #   if File.exists?(full_path_jpg)
  #     puts "Successfully copied embedded JPG art."
  #     md5 = Digest::MD5.hexdigest(File.read(full_path_jpg)) + File.extname(full_path_jpg)
  #
  #     destination = File.join(Settings.cover_art_cache, md5)
  #     FileUtils.copy(full_path_jpg, destination)
  #
  #     return File.basename(destination)
  #   elsif File.exists?(full_path_png)
  #     puts "Successfully copied embedded PNG art."
  #     md5 = Digest::MD5.hexdigest(File.read(full_path_png)) + File.extname(full_path_png)
  #
  #     destination = File.join(Settings.cover_art_cache, md5)
  #     FileUtils.copy(full_path_png, destination)
  #
  #     return File.basename(destination)
  #   else
  #     puts "Failed to find or copy embedded art."
  #   end
  #
  # end

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
          elsif picture.mime_type == 'image/flac'
            AudioMetadata::write_image_to_file!(picture.data, full_path_png)
          end
        end
      end
    elsif file_format == '.mp3'
      TagLib::MPEG::File.open(filename) do |file|
        tag = file.id3v2_tag

        if tag.frame_list('APIC').length > 0
          cover = tag.frame_list('APIC').first

          if cover.mime_type == 'image/jpeg'
            AudioMetadata::write_image_to_file!(cover.picture, full_path_jpg)
          elsif cover.mime_type == 'image/flac'
            AudioMetadata::write_image_to_file!(cover.picture, full_path_png)
          end
        end
      end
    end

    # now copy the /tmp file to the cover art cache and return it
      if File.exists?(full_path_jpg)
        puts "Successfully copied embedded JPG art."
        md5 = Digest::MD5.hexdigest(File.read(full_path_jpg)) + File.extname(full_path_jpg)

        destination = File.join(Settings.cover_art_cache, md5)
        FileUtils.copy(full_path_jpg, destination)

        return File.basename(destination)
      elsif File.exists?(full_path_png)
        puts "Successfully copied embedded PNG art."
        md5 = Digest::MD5.hexdigest(File.read(full_path_png)) + File.extname(full_path_png)

        destination = File.join(Settings.cover_art_cache, md5)
        FileUtils.copy(full_path_png, destination)

        return File.basename(destination)
      else
        puts "Failed to find or copy embedded art."
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
    elsif ".png"
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
        #pic.width = 90
        #pic.height = 90
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

end
