class Song
  include Mongoid::Document

  field :title, type: String
  field :artist, type: String
  field :album_artist, type: String
end
