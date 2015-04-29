class CoverArtController < ApplicationController
  def cover_art_cache
    album = Album.find(params[:album_id])

    if album.cover_art_cache_file
      file = File.join(Settings.cover_art_cache, album.cover_art_cache_file)
      send_file(file,
        disposition: 'inline',
        x_sendfile: true
      )
    else
      not_found
      # file = File.join(Rails.root, "public", "transparent.png")
      # send_file(file,
      #   type: "image/png")
    end
  end
end