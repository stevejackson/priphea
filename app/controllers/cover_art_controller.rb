class CoverArtController < ApplicationController
  def cover_art_cache
    album = Album.find(params[:album_id])

    if album.has_cover_art?
      file = if params[:thumbnail]
        File.join(Settings.cover_art_cache, album.cover_art_file_thumbnail_300)
      else
        File.join(Settings.cover_art_cache, album.cover_art_cache_file)
      end

      send_file(file,
        disposition: 'inline',
        x_sendfile: true
      )
    else
      not_found
    end
  end
end
