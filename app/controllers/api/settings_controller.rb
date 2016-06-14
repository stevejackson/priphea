class Api::SettingsController < ApplicationController
  protect_from_forgery except: [:rescan, :restart_priphea_backend]

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

end
