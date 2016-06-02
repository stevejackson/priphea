class Api::SettingsController < ApplicationController
  protect_from_forgery with: :null_session

  def rescan
    deep_scan = params.fetch(:deep_scan, false)

    background do
      scanner = LibraryScanner.new(Settings.library_path)
      scanner.scan(deep_scan)
    end

    render json: {}, status: 200
  end

end
