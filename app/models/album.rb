class Album

  include Mongoid::Document

  has_many :songs

  field :title, type: String
  field :cover_art_file, type: String
  field :cover_art_cache_file, type: String

  def self.find_by_title_or_create_new(title)
    album = Album.where(title: title).first_or_create
  end

  def has_cover_art?
    (cover_art_file || cover_art_cache_file?) ? true : false
  end

  def cover_art_cache_file_full_path
    has_cover_art? ? File.join(Settings.cover_art_cache, cover_art_cache_file) : nil
  end

  def update_cover_art_cache
    Rails.logger.debug "---- "
    Rails.logger.debug " Updating cover art cache for: #{self.inspect}"
    make_cache_directory

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
          self.save!
        end
      end

    end
  end


  def as_json(*args)
    res = super

    res["id"] = res.delete("_id").to_s
    res["has_cover_art"] = self.has_cover_art?

    res
  end

  def as_json_with_songs(*args)
    res = as_json(*args)
    res["id"] = res.delete("_id").to_s
    res["songs"] = self.songs.as_json
    res["has_cover_art"] = self.has_cover_art?

    res
  end

  private
    def make_cache_directory
      unless File.directory?(Settings.cover_art_cache)
        FileUtils.mkdir_p(Settings.cover_art_cache)
      end
    end


end
