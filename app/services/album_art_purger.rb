class AlbumArtPurger
  attr_accessor :album

  def initialize(album)
    @album = album
  end

  def purge_existing_art
    directories = []

    @album.songs.each do |song|
      unless directories.include?(File.dirname(song.full_path))
        directories << File.dirname(song.full_path)
      end
    end

    # check for existing cover art image files that exist in
    # the same location as all songs in this album
    directories.each do |directory|
      Album::COVER_ART_FILENAMES.each do |cover_art_filename|
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
