class Api::SongsController < ApplicationController
  def show
    song = Song.find(params[:id])
    render json: song.as_json
  end

  def update
    song = Song.find(params[:id])

    song.update_attributes(params)

    render json: song.as_json
  end
end
