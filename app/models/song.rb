require 'taglib'

class Song
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  include Mongoid::Timestamps

  belongs_to :album, index: true

  # metadata fields
  field :title, type: String
  field :artist, type: String
  field :album_artist, type: String
  field :track_number, type: Integer
  field :total_tracks, type: Integer
  field :disc_number, type: Integer
  field :total_discs, type: Integer
  field :album_artist, type: String
  field :duration, type: String
  field :year, type: String
  field :genre, type: String
  field :bpm, type: String
  field :composer, type: String
  field :comment, type: String
  field :bitrate, type: String
  field :filesize, type: String
  field :filetype, type: String

  # custom fields
  field :full_path, type: String
  field :file_date_modified, type: DateTime

  field :rating, type: Integer # out of 100

  # states: "missing", "active"
  field :state, type: String

  index( { rating: 1 }, { unique: false, name: "rating_index" })
  index( { state: 1 }, { unique: false, name: "state_index" })
  index( { full_path: 1 }, { unique: true, drop_dups: true, name: "full_path_index" })

  scope :active, -> { where(state: "active") }
  scope :missing, -> { where(state: "missing") }
  scope :unrated, -> { where(rating: nil) }

  after_save :update_album_active

  def update_album_active
    if self.album
      self.album.update_active
      self.album.save!
    end

    true
  end

  def self.build_from_file(filename, deep_scan=false)
    filename.unicode_normalize!
    # if this song already exists, find it first
    song = Song.find_by(full_path: filename) rescue nil

    # otherwise, create a new song from scratch
    song ||= self.new

    if !File.exists?(filename)
      # if the file doesn't exist, we still want to import
      #  keep this in the database. sometimes files will be
      #  changed or moved and reimported and their files are missing,
      #  but we want them in the database to save their ratings/tags.
      song.state = 'missing'
      return song
    end

    # if the file's "Date Modified" isn't any newer than the previous scan,
    # don't bother re-reading the metadata.
    mtime = File.mtime(filename).utc
    if song.file_date_modified && mtime.utc == song.file_date_modified.utc
      return song unless deep_scan
    else
      song.file_date_modified = mtime
    end

    # populate the model out of this file's metadata
    metadata = AudioMetadata.from_file(filename)

    fields = %w{title
      artist
      track_number
      disc_number
      duration
      year
      total_tracks
      total_discs
      album_artist
      genre
      composer
      comment
      filesize
      filetype}

    fields.each do |field_name|
      song.send(field_name + "=", metadata[field_name])
    end

    song.full_path = filename

    # find this song's album or create it if it's new
    if metadata["album"]
      song.album = Album.find_by_title_or_create_new(metadata['album'])
    end

    song.state = 'active'

    song
  end

  def as_json(*args)
    res = super

    res["id"] = res.delete("_id").to_s
    res["album_id"] = res["album_id"].to_s
    res["album"] = self.album.as_json

    res["has_cover_art"] = self.album.has_cover_art?

    res
  end

  def self.already_exists?(song)
    Song.where({ full_path: song.full_path }).exists?
  end

  def check_existence!
    if self.full_path && File.exists?(self.full_path)
      self.state = 'active'
    else
      self.state = 'missing'
    end

    self.save!
  end

  # write new embedded cover art metadata. erase all previous art in this metadata.
  def write_cover_art_to_metadata!(file_type, cover_art_data)
    Rails.logger.info "--- Trying to write cover art metadata for song #{self.id} - #{self.title}."
    AudioMetadata::write_cover_art_to_metadata!(self.full_path, cover_art_data, file_type)
  end

  def file_format
    File.extname(self.full_path).downcase
  end

  def flac?
    self.file_format == '.flac'
  end

  def mp3?
    self.file_format == '.mp3'
  end

end
