class MainController < ApplicationController

  def index
    Album.destroy_all
    Song.destroy_all

    scanner = Scanner.new(Settings.library_path)
    scanner.scan

    @albums = Album.all
  end

end
