class CoverArtController < ApplicationController
  def cover_art_cache
    album = Album.find(params[:album_id])

    if album.has_cover_art?
      # response.headers['cache-control'] = 'public, no-transform, max-age=300'
      # response.headers['cache-control'] = 'no-transform'
      
      file = File.join(Settings.cover_art_cache, album.cover_art_cache_file)
      send_file(file,
        disposition: 'inline',
        x_sendfile: true
      )
    else
      not_found
    end
  end
end
