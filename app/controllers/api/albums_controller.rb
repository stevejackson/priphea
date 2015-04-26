class Api::AlbumsController < ApplicationController
  def index
    render json: Album.all.as_json
  end

  def show
    album = Album.find(params[:id])
    puts '-----'
    puts "Album#show Returning JSON: "
    puts album.as_json
    puts '-----'
    render json: album.as_json
  end
end
