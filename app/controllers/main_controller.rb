class MainController < ApplicationController

  def index
    @albums = Album.asc(:title).all
    @albums = @albums.is_active
  end

  def rescan
    background do
      scanner = Scanner.new(Settings.library_path)
      scanner.scan
    end

    redirect_to root_path
  end

  def destroy_and_rescan
    Album.destroy_all
    Song.destroy_all

    scanner = Scanner.new(Settings.library_path)
    scanner.scan

    redirect_to root_path
  end

  def update_cover_art_cache
    Album.all.each do |album|
      album.update_cover_art_cache
    end

    redirect_to root_path
  end


end
