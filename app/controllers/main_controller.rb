class MainController < ApplicationController

  def index
    @albums = Album.asc(:title).all
  end

  def rescan
    Album.destroy_all
    Song.destroy_all

    scanner = Scanner.new(Settings.library_path)
    scanner.scan

    redirect_to root_path
  end


end
