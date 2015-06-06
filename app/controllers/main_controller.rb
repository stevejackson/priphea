class MainController < ApplicationController
  layout 'player'

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

  def scan_for_file_notification_changes
    FileNotificationProcessor.process!

    redirect_to root_path
  end

  def check_file_existence
    song_count = Song.count

    Song.all.each_with_index do |song, index|
      Rails.logger.info "--- Song existence index: #{index}/#{song_count}"

      song.check_existence!
    end

    redirect_to root_path
  end

  def delete_missing_unrated_files
    songs = Song.missing.unrated
    song_count = songs.count

    songs.each_with_index do |song, index|
      Rails.logger.info "--- Deleting unrated, missing songs: #{index}/#{song_count}"

      song.delete
    end

    redirect_to root_path
  end


end
