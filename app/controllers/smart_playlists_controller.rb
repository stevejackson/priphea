class SmartPlaylistsController < ApplicationController
  def new
    @smart_playlist = SmartPlaylist.new
  end

  def create
    @smart_playlist = SmartPlaylist.new(params[:smart_playlist])

    if @smart_playlist.save
      redirect_to root_path
    else
      render :new
    end
  end

  def edit
    @smart_playlist = SmartPlaylist.find(params[:id])
  end

  def update
    @smart_playlist = SmartPlaylist.find(params[:id])
    @smart_playlist.update_attributes(params[:smart_playlist])

    if @smart_playlist.save
      redirect_to root_path
    else
      render :edit
    end
  end

  def destroy
    @smart_playlist = SmartPlaylist.find(params[:id])

    if @smart_playlist.destroy
      redirect_to root_path
    else
      render :edit
    end
  end
end
