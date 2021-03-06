class AlbumsController < ApplicationController

  def edit
    @album = Album.find(params[:id])
  end

  def update
    @album = Album.find(params[:id])
    @album.update_attributes(params[:album])

    if @album.save
      CoverArtUpdater.new(@album).update_cover_art
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

  def delete_all_songs_from_database_with_files
    album = Album.find(params[:id])

    if album
      album.songs.each do |song|
        Rails.logger.info "Deleting #{song} from filesystem & database..."
        song.delete_source_file!
        song.delete
      end

      album.delete
    end

    redirect_to root_path
  end

  def update_all_songs_metadata
    album = Album.includes(:songs).find(params[:id])
    album.update_attributes(params.require(:album).permit(:songs_attributes => ["id"] + Song::WRITABLE_FIELDS))

    if album.save
      if album.write_all_songs_metadata_to_source_files
        redirect_to edit_album_path(album), notice: "Successfully saved all songs in this album & updated source files with new metadata."
      else
        render :edit, alert: "Saved metadata to priphea database, but failed to write metadata to source files."
      end
    else
      render :edit, alert: "Failed to save metadata to priphea database, and did not write metadata to source files."
    end
  end

  def deep_rescan_specific_directory
    path = params[:path]

    background do
      LibraryScanner.new(path).scan(true)
    end

    redirect_to root_path
  end

end
