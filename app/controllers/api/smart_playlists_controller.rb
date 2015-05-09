class Api::SmartPlaylistsController < ApplicationController
  def index
    playlists = SmartPlaylist.all

    if playlists.any?
      render json: playlists.as_json
    else
      render json: {}, status: 204
    end
  end

  def show
    playlist = SmartPlaylist.find(params[:id])

    if playlist
      render json: playlist.as_json_with_songs
    else
      render json: {}, status: 204
    end
  end
end
