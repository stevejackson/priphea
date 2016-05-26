class Api::AlbumsController < ApplicationController
  protect_from_forgery with: :null_session

  def index
    albums =  Album.asc(:title).all
    query = params[:query]

    if query.present?
      # is this a search for recent albums?
      if query.match(/^(recent) (\d*)/i)
        albums = albums.recently_created($2.to_i).asc(:title)
      else # normal search
        ransack_search_query = {
          search_terms_special_match: query
        }

        q = Album.ransack(ransack_search_query)
        albums = q.result.asc(:title)
      end
    end

    render json: albums.as_json
  end

  def show
    album = Album.find(params[:id])

    if album
      render json: album.as_json_with_songs
    else
      render json: {}, status: 404
    end
  end

  def change_album_art
    album = Album.find(params[:id])
    uploaded_io = params[:file]
    file_type = File.extname(uploaded_io.original_filename).downcase

    album.write_new_album_art!(file_type, uploaded_io.read)

    render json {}, status: 200
  end

end
