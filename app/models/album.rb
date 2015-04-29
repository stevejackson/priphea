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
    cover_art_file || cover_art_cache_file?
  end

  def update_cover_art_cache
    make_cache_directory()
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

        puts "Checking if file exists: #{file}"

        if File.exists?(file)
          puts "File exists: #{file}"
          self.cover_art_file = file

          md5 = Digest::MD5.hexdigest(File.read(file)) + File.extname(file)
          cache_location = File.join(Settings.cover_art_cache, md5)

          FileUtils.copy(file, cache_location)

          self.cover_art_cache_file = md5
          self.save!

          break
        end
      end

    end
  end


  def as_json(*args)
    res = super

    res["id"] = res.delete("_id").to_s
    res["songs"] = self.songs.as_json

    res
  end

  private
    def make_cache_directory
      unless File.directory?(Settings.cover_art_cache)
        FileUtils.mkdir_p(Settings.cover_art_cache)
      end
    end


end
