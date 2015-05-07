class Player
  attr_accessor :song_queue
  attr_accessor :active_song

  def initialize
    @song_queue ||= []
  end

  def play
    @active_song = @song_queue.shift

    if @active_song
      cli_command = %Q{ cmus-remote --file "#{@active_song.full_path}" }
      system(cli_command)
    end
  end

  # is the current song finished playing?
  def finished_song?
    results = self.status
    puts "Checking if song is finished playing: #{results[:position]} / #{results[:duration]}"
    if results[:position] == results[:duration]
      true
    else
      false
    end
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

  def status
    cli_command = %Q{ cmus-remote --query }
    output = %x[cmus-remote --query]
    results = parse_status_into_hash(output)

    puts "Got results of cmus-remote --query into hash: #{results.inspect}"

    if %w(playing).include?(results[:status])
      puts "Playing!"
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