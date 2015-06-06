require 'fileutils'
require 'json'

class SettingsController < ApplicationController
  
  def index
    @settings = load_settings_from_file
  end

  def save
    settings = settings_params
    save_user_settings(settings)

    if true
      redirect_to root_path
    else
      render :index
    end
  end

  private

    def load_settings_from_file
      filename = "/Users/steve/.config/priphea/config.json"
      begin
        file = File.read(filename)
      rescue => e
        puts e.message
        puts e.backtrace.join("\n")
      end

      if file
        result = JSON.parse(file)
        HashWithIndifferentAccess.new(result)
      else
        {}
      end
    end

    def save_user_settings(settings)
      filename = "/Users/steve/.config/priphea/config.json"
      dirname = File.dirname(filename)
      unless File.directory?(dirname)
        FileUtils.mkdir_p(dirname)
      end

      File.delete(filename) if File.exists?(filename)
      File.open(filename, "w") do |f|
        f.puts settings.to_json
      end
    end

    def settings_params
      params.permit(:library_path)
    end
end
