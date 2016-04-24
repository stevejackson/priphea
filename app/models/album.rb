class Album
  include Mongoid::Document
  include Mongoid::Timestamps

  COVER_ART_FILENAMES = %w[
    cover.jpg cover.JPG
    cover.jpeg cover.JPEG
    cover.png cover.PNG
    folder.jpg folder.JPG
    folder.jpeg folder.JPEG
    folder.png folder.PNG
  ]

  has_many :songs
  accepts_nested_attributes_for :songs
  validates_associated :songs

  field :title, type: String

  field :cover_art_file, type: String
  field :cover_art_cache_file, type: String
  field :cover_art_width, type: Integer
  field :cover_art_height, type: Integer

  field :cover_art_file_thumbnail_300, type: String
  field :cover_art_file_thumbnail_500, type: String

  field :custom_tags, type: String

  field :search_terms, type: String

  field :active, type: Boolean

  scope :is_active, -> { where(active: true) }
  scope :recently_created, -> (number_of_days) {
    updated_after = DateTime.now - number_of_days.days
    where(:created_at.gte => updated_after)
  }

  before_save :update_search_terms
  before_save :update_active

  def update_active
    self.active = (self.songs.any? && self.songs.active.count > 0)

    true
  end

  def self.find_by_title_or_create_new(title)
    album = Album.where(title: title).first_or_create
  end

  def has_cover_art?
    (cover_art_file || cover_art_cache_file) ? true : false
  end

  def cover_art_cache_file_full_path
    has_cover_art? ? File.join(Settings.cover_art_cache, cover_art_cache_file) : nil
  end

  def update_search_terms
    artist = ""
    album_artist = ""

    if self.songs.any?
      artist = self.songs.first.artist
      album_artist = self.songs.first.album_artist
    end

    terms = "#{self.title} #{artist} #{album_artist} #{self.custom_tags}"
    self.search_terms = SearchUtils::search_format(terms)
  end

  def as_json(*args)
    res = super

    res["id"] = res.delete("_id").to_s
    res["has_cover_art"] = self.has_cover_art?
    res["active"] = self.active?

    res
  end

  def as_json_with_songs(*args)
    res = self.as_json

    res["songs"] = self.songs.active.as_json

    res
  end

  # delete album's existing cover art, write this new image to disk as "cover.jpg",
  # then embed it in each song as its cover art.
  def write_new_album_art!(file_type, cover_art_data)
    first_active_song = self.songs.active.first
    full_new_cover_art_name = File.join(File.dirname(first_active_song.full_path), "cover" + file_type)

    AlbumArtPurger.new(self).purge_existing_art

    # write art to disk
    self.write_image_to_file!(cover_art_data, full_new_cover_art_name)

    # write art to embedded metadata
    self.write_image_to_songs_metadata!(file_type, cover_art_data)

    CoverArtUpdater.new(self).update_cover_art
  end

  def write_image_to_songs_metadata!(file_type, cover_art_data)
    self.songs.each do |song|
      song.write_cover_art_to_metadata!(file_type, cover_art_data)
    end
  end

  def delete_existing_cover_art_files!
    cover_art_manager = CoverArtManager.new
    cover_art_manager.clear_existing_cover_art_files_of_album(self)
  end

  def write_image_to_file!(cover_art_data, filename)
    File.open(filename, 'wb') do |file|
      file.write(cover_art_data)
    end
  end

  def write_all_songs_metadata_to_source_files
    songs.each do |song|
      song.write_metadata_to_file!
    end
  end

    def self.ransackable_attributes(auth_object = nil)
      # whitelist the following attributes to be searchable
      super & %w(search_terms)
    end

end
