class Song
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic

  belongs_to :album

  field :full_path, type: String

  field :title, type: String
  field :artist, type: String
  field :track_number, type: String
  field :disc_number, type: String
  field :album_artist, type: String
  field :rating, type: Integer # out of 100

  def self.build_from_file(filename)
    song = self.new

    metadata = AudioMetadata.from_file(filename)

    fields = %w{title artist track_number disc_number}

    fields.each do |field_name|
      song.send(field_name + "=", metadata[field_name])
    end

    song.full_path = filename

    # find this song's album or create it if it's new
    if metadata["album"]
      song.album = Album.find_by_title_or_create_new(metadata['album'])
    end

    song
  end

  def as_json(*args)
    res = super

    res["id"] = res.delete("_id").to_s
    res["album_id"] = res["album_id"].to_s

    res["has_cover_art"] = self.album.has_cover_art?

    res
  end

end
