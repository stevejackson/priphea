class Api::SongsController < ApplicationController
  def index
    # is this a request to return the active playback queue?
    if params[:playback_queue]
      render json: $player.song_queue.collect(&:as_json)
    end
  end

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
