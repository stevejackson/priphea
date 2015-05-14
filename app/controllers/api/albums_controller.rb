class Api::AlbumsController < ApplicationController
  def index
    albums =  Album.asc(:title).all
    if params[:q].present? && params[:q][:search_terms_special_match].present? && !params[:q][:search_terms_special_match].blank?
      #binding.pry
      q = Album.ransack(params[:q])
      albums = q.result.asc(:title)
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

end
