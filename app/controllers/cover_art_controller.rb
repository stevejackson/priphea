class CoverArtController < ApplicationController
  def cover_art_cache
    album = Album.find(params[:album_id])

    if album.cover_art_cache_file
      file = File.join(Settings.cover_art_cache, album.cover_art_cache_file)
      send_file(file,
        disposition: 'inline',
        x_sendfile: true
      )
    end
  end
end
