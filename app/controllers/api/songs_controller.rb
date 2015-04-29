class Api::SongsController < ApplicationController
  def show
    song = Song.find(params[:id])
    render json: song.as_json
  end
end
