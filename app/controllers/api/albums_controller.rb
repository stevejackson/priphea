class Api::AlbumsController < ApplicationController
  def index
    albums =  Album.asc(:title).all
    if params[:q].present? && params[:q][:search_terms_special_match].present? && !params[:q][:search_terms_special_match].blank?
      q = Album.ransack(params[:q])
      albums = q.result.asc(:title)
    end

    render json: albums.as_json
  end

  def show
    album = Album.find(params[:id])
    puts '-----'
    puts "Album#show Returning JSON: "
    puts album.as_json
    puts '-----'
    render json: album.as_json_with_songs
  end
end
