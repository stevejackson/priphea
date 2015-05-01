class AudioMetadata
  def self.from_file(filename)
    song = MiniExiftool.new(filename)
    file_extension = File.extname(filename)

    metadata = {}

    if %w(.mp3 .MP3).include?(file_extension)
      metadata['track_number'] = AudioMetadata::mp3_track_number(song.track.to_s)
      metadata['disc_number'] = AudioMetadata::mp3_disc_number(song.part_of_set.to_s)
    elsif %w(.flac .FLAC).include?(file_extension)
      metadata['track_number'] = song.track_number
      metadata['disc_number'] = song.disc
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

  def self.copy_embedded_art_to_cache(filename)
    # for now, 4 commands can be run to try and export art. after, we'll check
    # if any of the art was extracted by exiftool.

    # if so, we'll copy it to the cover art cache and return the filename.

    random_string = Random.rand(2000000).to_s

    full_path_jpg = File.join("/", "tmp", "#{random_string}.jpg")
    full_path_png = File.join("/", "tmp", "#{random_string}.png")

    null = ">/dev/null 2>&1"

    output = system %Q{ exiftool -if '$picturemimetype eq "image/jpeg"' -picture -b -w #{full_path_jpg}%c -ext flac "#{filename}" #{null} }
    output =system %Q{ exiftool -if '$picturemimetype eq "image/png"' -picture -b -w #{full_path_png}%c -ext flac "#{filename}" #{null} }

    output = system %Q{ exiftool -if '$picturemimetype eq "image/jpeg"' -picture -b -w #{full_path_jpg}%c -ext mp3 "#{filename}" #{null} }
    output = system %Q{ exiftool -if '$picturemimetype eq "image/png"' -picture -b -w #{full_path_png}%c -ext mp3 "#{filename}" #{null} }

    if File.exists?(full_path_jpg)
      md5 = Digest::MD5.hexdigest(File.read(full_path_jpg)) + File.extname(full_path_jpg)

      destination = File.join(Settings.cover_art_cache, md5)
      FileUtils.copy(full_path_jpg, destination)

      return File.basename(destination)
    elsif File.exists?(full_path_png)
      md5 = Digest::MD5.hexdigest(File.read(full_path_png)) + File.extname(full_path_png)

      destination = File.join(Settings.cover_art_cache, md5)
      FileUtils.copy(full_path_png, destination)

      return File.basename(destination)
    end

  end
end
