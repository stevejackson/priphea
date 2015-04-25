class MainController < ApplicationController

  def index
    # (875..1311).each do |i|
    #   album = Album.new
    #   album.title = "Album title of Fakeness #{i}"
    #   album.cover_art_url = "/fakecovers/#{i}"
    #   album.save!
    # end
    @albums = Album.all
  end

end
