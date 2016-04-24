class SongScanner
  attr_accessor :filename
  attr_accessor :deep_scan
  attr_accessor :metadata
  attr_accessor :song
  attr_accessor :mtime

  def initialize(filename, deep_scan)
    @filename = filename.unicode_normalize
    @deep_scan = deep_scan
    @metadata = nil
    @song = nil

    fetch_song_record
  end

  def fetch_song_record
    @song = Song.find_by(full_path: @filename) rescue nil

    # if we couldn't find the song by it's full_path, it may be a new song -
    # but first, check if it is an existing song that was just moved in the filesystem
    if @song.nil?
      load_metadata_from_file_into_hash
      if (id = AudioMetadata.extract_priphea_id_from_comment(@metadata['comment']))
        @song = Song.find(id) rescue nil
      end
    end

    # otherwise, create a new song from scratch
    @song ||= Song.new
  end

  def file_is_missing?
    if !File.exist?(@filename)
      # if the file doesn't exist, we still want to
      #  keep this in the database. sometimes files will be
      #  changed or moved and reimported and their files are missing,
      #  but we want them in the database to save their ratings/tags.
      @song.state = 'missing'
      return true
    end

    false
  end

  def song_is_unmodified?
    @mtime = File.mtime(@filename).utc
    @mtime = DateTime.parse(@mtime.to_s).utc if @mtime

    unmodified = (@song.file_date_modified && @mtime.to_s == @song.file_date_modified.utc.to_s)
    Rails.logger.debug "Unmodified?: #{unmodified}"
    unmodified
  end

  def load_metadata_from_file_into_hash
    @metadata ||= AudioMetadata.from_file(@filename)
  end

  def write_priphea_id_to_file_metadata
    @metadata['comment'] = AudioMetadata.generate_priphea_id_comment(@metadata['comment'], @song)
    AudioMetadata::write_tag(@filename, "comment", @metadata['comment'])
  end

  def load_file_metadata_into_song_record
    Song::METADATA_FIELDS.each do |field_name|
      @song.send(field_name + "=", @metadata[field_name])
    end

    @song.full_path = @filename
    @song.state = "active"
    @song.file_date_modified = @mtime
  end

  def create_album_association
    @song.create_album_association_from_string(@metadata['album'])
  end

  def reset_song_mtime
    now = DateTime.now.utc
    @mtime = now

    @song.file_date_modified = @mtime
    FileUtils.touch @song.full_path, mtime: Time.parse(@mtime.to_s)
  end

  def scan_file
    return @song if file_is_missing?
    return @song if song_is_unmodified? && !@deep_scan

    load_metadata_from_file_into_hash
    write_priphea_id_to_file_metadata
    load_file_metadata_into_song_record
    create_album_association
    reset_song_mtime

    @song
  end
end
