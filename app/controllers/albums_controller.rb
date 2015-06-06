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

  def delete_all_songs_from_database
    album = Album.find(params[:id])

    if album
      album.songs.each do |song|
        Rails.logger.info "Deleting #{song} from database..."
        song.delete
      end
    end

    redirect_to root_path
  end

end
