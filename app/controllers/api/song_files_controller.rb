class Api::SongFilesController < ApplicationController

  def show
    song = Song.find(params[:id])

    if song && song.full_path
      ext = File.extname(song.full_path)
      file = File.join(song.full_path)
      size = File.size(song.full_path)

      response.headers['Content-Length'] = size.to_s

      if %w(.mp3 .MP3).include?(ext)
        send_file(file,
          type: :mp3,
          buffer_size: 1024,
          x_sendfile: true
        )
      elsif %w(.flac .FLAC).include?(ext)
        send_file(file,
          type: :flac,
          buffer_size: 1024,
          x_sendfile: true
        )
      end
    else
      not_found
    end
  end

end
