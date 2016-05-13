class AudioPlayer
  attr_accessor :song_queue
  attr_accessor :active_song

  def initialize
    @song_queue ||= []
  end

  def play
    @active_song = @song_queue.first

    if @active_song
      cli_command = %Q{ cmus-remote --file "#{@active_song.full_path}" }
      system(cli_command)
    end
  end

  # is the current song finished playing?
  def finished_song?
    results = self.status

    results[:position] == results[:duration]
  end

  def resume
    cli_command = %Q{ cmus-remote --play }
    system(cli_command)
  end

  def pause
    cli_command = %Q{ cmus-remote --pause }
    system(cli_command)
  end

  def set_volume(volume_percent)
    cli_command = %Q{ cmus-remote --volume #{volume_percent} }
    system(cli_command)
  end

  # takes a percent like "50"
  def seek(percent)
    # cmus-remote --seek takes a parameter in seconds.
    results = self.status
    if status[:duration]
      # example:
      # --------
      # duration: 90 seconds
      # percent to seek: 50
      # 90.0f * (50 / 100)
      # 90 * 0.5
      # 45 seconds

      duration = status[:duration].to_f
      percent = percent.to_f * 0.01

      seek_seconds = (duration * percent).to_i
      cli_command = %Q{ cmus-remote --seek #{seek_seconds} }

      system(cli_command)
    end
  end

  def next_song
    @song_queue.shift
    self.play
  end

  def status
    output = %x[cmus-remote --query]
    results = parse_status_into_hash(output)

    if %w(playing).include?(results[:status])
      results[:song] = @active_song.as_json
    end

    results
  end

  private

    # read the status of cmus-remote --query command
    def parse_status_into_hash(output)
      hash = HashWithIndifferentAccess.new

      output.each_line do |line|
        if line.match /(^.*) (.*)/
          hash[$1] = $2
        end
      end

      hash
    end
end
