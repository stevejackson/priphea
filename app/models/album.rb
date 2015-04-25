class Album
  include Mongoid::Document

  field :title, type: String
  field :cover_art_url, type: String
end
