class Song
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  include Mongoid::Timestamps

  belongs_to :album

  # metadata fields
  field :title, type: String
  field :artist, type: String
  field :track_number, type: String
  field :disc_number, type: String
  field :album_artist, type: String
  field :duration, type: String

  # custom fields
  field :full_path, type: String
  field :file_date_modified, type: DateTime

  field :rating, type: Integer # out of 100

  # states: "missing", "active"
  field :state, type: String

  index( { rating: 1 }, { unique: false, name: "rating_index" })
  index( { state: 1 }, { unique: false, name: "state_index" })

  scope :active, -> { where(state: "active") }

  after_save :update_album_active

  def update_album_active
    if self.album
      self.album.update_active
      self.album.save!
    end

    true
  end

  def self.build_from_file(filename)
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
      return song
    else
      song.file_date_modified = mtime
    end

    # populate the model out of this file's metadata
    metadata = AudioMetadata.from_file(filename)

    fields = %w{title artist track_number disc_number duration}

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

end
