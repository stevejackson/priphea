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

  def change_album_art
    album = Album.find(params[:id])

    uploaded_io = params[:file]

    file_type = File.extname(uploaded_io.original_filename).downcase

    album.write_new_album_art!(file_type, uploaded_io.read)

    render :json => {}, status: 200
  end

end
