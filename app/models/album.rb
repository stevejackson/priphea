class Album
  include Mongoid::Document
  include Mongoid::Timestamps

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

  def update_cover_art_cache
    Rails.logger.debug "---- "
    Rails.logger.debug " Updating cover art cache for: #{self.inspect}"
    make_cache_directory
    self.cover_art_cache_file = nil
    self.cover_art_file = nil

    if songs.any?
      song = songs.first
      song_directory = File.dirname(song.full_path)

      cover_art_filenames = %w[
        cover.jpg cover.JPG
        cover.jpeg cover.JPEG
        cover.png cover.PNG
        folder.jpg folder.JPG
        folder.jpeg folder.JPEG
        folder.png folder.PNG
      ]

      # check for existing cover art image files that exist in
      # the same location as a song in this album
      cover_art_filenames.each do |cover_art_filename|
        file = File.join(song_directory, cover_art_filename)

        Rails.logger.info "Checking if file exists: #{file}"

        if File.exists?(file)
          Rails.logger.info "File exists: #{file}"
          self.cover_art_file = file

          md5 = Digest::MD5.hexdigest(File.read(file)) + File.extname(file)
          cache_location = File.join(Settings.cover_art_cache, md5)

          FileUtils.copy(file, cache_location)

          image_size = ImageMetadata::image_size(cache_location)
          self.cover_art_width = image_size[:width]
          self.cover_art_height = image_size[:height]

          self.cover_art_cache_file = md5
          self.save!

          break
        end
      end

      # if cover art file does not exist, we should also check a song in this
      # album for embedded art.
      if self.cover_art_cache_file.blank?
        song = self.songs.first
        Rails.logger.info "Trying to extract embedded art from: #{song.inspect}"

        cache_location = AudioMetadata.copy_embedded_art_to_cache(song.full_path)
        Rails.logger.info "Cache location: #{cache_location}"

        if cache_location
          self.cover_art_cache_file = cache_location

          full_art_path = File.join(Settings.cover_art_cache, cache_location)
          image_size = ImageMetadata::image_size(full_art_path)
          self.cover_art_width = image_size[:width]
          self.cover_art_height = image_size[:height]

          self.save!
        end
      end

      # make thumbnail cache version, 500px
      unless self.cover_art_cache_file.blank?
        Rails.logger.info "Trying to make a 500px thumbnail version of album art."

        output_filename = self.cover_art_cache_file + "_500"
        Rails.logger.info "Outputting to file: #{output_filename}"

        ImageProcessing::make_thumbnail_500(
          File.join(Settings.cover_art_cache, self.cover_art_cache_file),
          File.join(Settings.cover_art_cache, output_filename)
        )

        self.cover_art_file_thumbnail_500 = output_filename
        self.save!
      end

      # make thumbnail cache version, 500px
      unless self.cover_art_cache_file.blank?
        Rails.logger.info "Trying to make a 300px thumbnail version of album art."

        output_filename = self.cover_art_cache_file + "_300"
        Rails.logger.info "Outputting to file: #{output_filename}"

        ImageProcessing::make_thumbnail_300(
          File.join(Settings.cover_art_cache, self.cover_art_cache_file),
          File.join(Settings.cover_art_cache, output_filename)
        )

        self.cover_art_file_thumbnail_300 = output_filename
        self.save!
      end
    end

    self.save!
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

    # delete any existing cover art files
    self.delete_existing_cover_art_files!

    # write art to disk
    self.write_image_to_file!(cover_art_data, full_new_cover_art_name)

    # write art to embedded metadata
    self.write_image_to_songs_metadata!(file_type, cover_art_data)

    self.update_cover_art_cache
  end

  def write_image_to_songs_metadata!(file_type, cover_art_data)
    self.songs.each do |song|
      song.write_cover_art_to_metadata!(file_type, cover_art_data)
    end
  end

  def delete_existing_cover_art_files!
    cover_art_filenames = %w[
      cover.jpg cover.JPG
      cover.jpeg cover.JPEG
      cover.png cover.PNG
      folder.jpg folder.JPG
      folder.jpeg folder.JPEG
      folder.png folder.PNG
    ]

    directories = []

    self.songs.each do |song|
      unless directories.include?(File.dirname(song.full_path))
        directories << File.dirname(song.full_path)
      end
    end

    # check for existing cover art image files that exist in
    # the same location as all songs in this album
    directories.each do |directory|
      cover_art_filenames.each do |cover_art_filename|
        file = File.join(directory, cover_art_filename)

        Rails.logger.info "Checking if file exists: #{file}"

        if File.exists?(file)
          Rails.logger.info "Found cover art, deleting: #{file}"
          File.delete(file)
        end
      end
    end
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

  private
    def make_cache_directory
      unless File.directory?(Settings.cover_art_cache)
        FileUtils.mkdir_p(Settings.cover_art_cache)
      end
    end

    def self.ransackable_attributes(auth_object = nil)
      # whitelist the following attributes to be searchable
      super & %w(search_terms)
    end


end
