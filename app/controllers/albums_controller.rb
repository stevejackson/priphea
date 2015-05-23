class AlbumsController < ApplicationController

  def edit
    @album = Album.find(params[:id])
  end

  def update
    @album = Album.find(params[:id])
    @album.update_attributes(params[:album])

    if @album.save
      @album.update_cover_art_cache
      redirect_to root_path
    else
      render :edit
    end
  end

end
