class MainController < ApplicationController
  def index
    song = Song.new
    song.title = "Test title"
    song.artist = "heimrich"
    song.save!
  end
end
