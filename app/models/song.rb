class Song
  include Mongoid::Document

  belongs_to :album

  field :full_path, type: String

  field :title, type: String
  field :artist, type: String
  field :album_artist, type: String

  def self.build_from_file(filename)
    song = self.new

    metadata = AudioMetadata.from_file(filename)

    song.title = metadata.title
    song.artist = metadata.artist
    song.full_path = filename

    # find this song's album or create it if it's new
    if metadata.album
      song.album = Album.find_by_title_or_create_new(metadata.album)
    end

    song
  end

  def as_json(*args)
    res = super

    res["id"] = res.delete("_id").to_s
    res["album_id"] = res["album_id"].to_s

    res
  end

end
