class Api::SongFilesController < ApplicationController

  def show
    song = Song.find(params[:id])

    if song && song.full_path
      file = File.join(song.full_path)
      size = File.size(song.full_path)

      response.headers['Content-Length'] = size.to_s

      send_file(
        file,
        type: song.mime_type,
        buffer_size: 1024,
        x_sendfile: true
      )
    else
      not_found
    end
  end

end
