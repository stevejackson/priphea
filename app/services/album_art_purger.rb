class AlbumArtPurger
  attr_accessor :album

  def initialize(album)
    @album = album
  end

  def purge_existing_art
    directories_with_songs = []

    @album.songs.each do |song|
      song_directory_name = File.dirname(song.full_path)

      unless directories_with_songs.include?(song_directory_name)
        directories_with_songs << song_directory_name
      end
    end

    directories_with_songs.each do |directory|
      Album::COVER_ART_FILENAMES.each do |cover_art_filename|
        file = File.join(directory, cover_art_filename)
        File.delete(file) if File.exist?(file)
      end
    end
  end
end
