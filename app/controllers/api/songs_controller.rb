class Api::SongsController < ApplicationController
  protect_from_forgery with: :null_session

  def index
    # is this a request to return the active playback queue?
    if params[:playback_queue]
      $player.song_queue.each(&:reload)
      render json: $player.song_queue.collect(&:as_json)
    end
  end

  def show
    song = Song.find(params[:id])
    render json: song.as_json
  end

  def update
    song = Song.find(params[:id])
    song.attributes = params.require(:song).permit(:rating)

    if song.save
      render json: song.as_json
    else
      render json: song.as_json, status: 500
    end
  end
end
