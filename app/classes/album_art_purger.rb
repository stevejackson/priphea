class AlbumArtPurger
  attr_accessor :album

  def initialize(album)
    @album = album
  end

  def purge_existing_art
    cover_art_filenames = %w[
      cover.jpg cover.JPG
      cover.jpeg cover.JPEG
      cover.png cover.PNG
      folder.jpg folder.JPG
      folder.jpeg folder.JPEG
      folder.png folder.PNG
    ]

    directories = []

    @album.songs.each do |song|
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
end
