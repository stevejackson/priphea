class Api::SettingsController < ApplicationController
  protect_from_forgery except: [:rescan, :restart_priphea_backend, :update_cover_art_cache]

  def rescan
    deep_scan = params.fetch(:deep_scan, false)

    background do
      scanner = LibraryScanner.new(Settings.library_path)
      scanner.scan(deep_scan)
    end

    render json: {}, status: 200
  end

  def restart_priphea_backend
    cmd = %{.#{Rails.root}/run.sh}

    background do
      system(cmd)
    end

    render json: {}, status: 200
  end

  def update_cover_art_cache
    Album.all.each do |album|
      CoverArtUpdater.new(album).update_cover_art
    end

    render json: {}, status: 200
  end

end
