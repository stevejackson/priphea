require 'taglib'

class Song
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  include Mongoid::Timestamps

  belongs_to :album, index: true

  validates_presence_of :album

  # metadata fields
  field :title, type: String
  field :artist, type: String
  field :album_artist, type: String
  field :album_title, type: String
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

  METADATA_FIELDS = %w{title
    artist
    album_artist
    album_title
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
    filetype
  }

  WRITABLE_FIELDS = %w{
    comment
    title
    artist
    album_artist
    disc_number
    track_number
    album_title
  }

  # custom fields
  field :full_path, type: String
  field :file_date_modified, type: DateTime

  field :rating, type: Integer # out of 100

  # states: "missing", "active"
  field :state, type: String

  index({ rating: 1 }, { unique: false, name: "rating_index" })
  index({ state: 1 }, { unique: false, name: "state_index" })
  index({ full_path: 1 }, { unique: true, drop_dups: true, name: "full_path_index" })

  scope :active, -> { where(state: "active") }
  scope :missing, -> { where(state: "missing") }
  scope :unrated, -> { where(rating: nil) }

  after_save :update_album_active
  before_save :update_album_association, if: Proc.new { |song| song.album_title_changed? }

  def update_album_active
    if self.album
      self.album.update_active
      self.album.save!
    end

    true
  end

  def self.build_song_from_file(filename, deep_scan=false)
    song_scanner = SongScanner.new(filename, deep_scan)
    song = song_scanner.scan_file
    song
  end

  def create_album_association_from_string(album_name)
    self.album_title = album_name
    album_name ||= "Untitled"

    self.album = Album.find_by_title_or_create_new(album_name)
  end

  def update_album_association
    create_album_association_from_string(self.album_title)
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

  def delete_source_file!
    Rails.logger.info "Attempting to delete song #{self.id}'s source file: #{self.full_path}'"

    if self.full_path && File.exists?(self.full_path)
      FileUtils.rm(self.full_path)
    end
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

  def write_metadata_to_file!
    (Song::WRITABLE_FIELDS).each do |field_name|
      AudioMetadata::write_tag(self.full_path, field_name, self.send(field_name))
    end
  end

end
