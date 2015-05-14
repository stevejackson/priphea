class Song
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  include Mongoid::Timestamps # created_at & updated_at

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

  field :rating, type: Integer # out of 100

  field :state, type: String

  # indices
  index( { rating: 1 }, { unique: false, name: "rating_index" })
  index( { state: 1 }, { unique: false, name: "state_index" })

  scope :active, -> { where(state: "active") }

  after_save :update_album_active

  def update_album_active
    if self.album
      self.album.update_active
      self.album.save!
    end
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

    metadata = AudioMetadata.from_file(filename)

    fields = %w{title artist track_number disc_number duration}

    fields.each do |field_name|
      song.send(field_name + "=", metadata[field_name])
    end
    puts song.inspect

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

end
