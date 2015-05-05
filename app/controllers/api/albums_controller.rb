class Api::AlbumsController < ApplicationController
  def index
    albums =  Album.asc(:title).all
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
