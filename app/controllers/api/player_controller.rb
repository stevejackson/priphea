class Api::PlayerController < ApplicationController
  protect_from_forgery with: :null_session

  def set_song_queue
    song_ids = params[:song_queue]

    if song_ids && !song_ids.empty?
      songs = song_ids.collect { |id| Song.find(id) }

      $player.song_queue = songs
    end

    render json: {}, status: 200
  end

  def set_song_queue_and_play
    song_ids = params[:song_queue]

    unless song_ids.empty?
      songs = song_ids.collect { |id| Song.find(id) }
      $player.song_queue = songs
    end

    $player.play

    render json: {}, status: 200
  end

  def set_volume
    $player.set_volume(params[:volume])

    render json: {}, status: 200
  end

  def pause
    $player.pause
    render json: {}, status: 200
  end

  def resume
    $player.resume
    render json: {}, status: 200
  end

  def seek
    $player.seek(params[:percent])
    render json: {}, status: 200
  end

  def update_and_get_status
    if $player.finished_song?
      $player.next_song
      $player.play
    end

    status = $player.status

    render json: status
  end

  def next_song
    $player.next_song
    render json: {}, status: 200
  end
end
