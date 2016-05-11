module MetadataExtractors
  class FlacMetadataExtractor < AbstractMetadataExtractor

    def track_number
      @file_metadata.track_number
    end

    # flac sometimes uses `disc` tag, sometimes `disc_number`, sometimes
    # in format 1/2, convert this to 1
    def disc_number
      disc_number_string = @file_metadata.disc_number || @file_metadata.disc

      if disc_number_string && disc_number_string.is_a?(String) && (index = disc_number_string.index('/'))
        disc_number_string[0, index]
      else
        disc_number_string
      end
    end

    def total_tracks
      @file_metadata.total_tracks
    end

    def total_discs
      @file_metadata.total_discs.try!(:to_s) || nil
    end

    # in format like: 0:02:43 (approx)
    def duration
      duration = @file_metadata.duration.to_s

      # in format like: 0:02:43 (approx)
      if duration.match /(\d{1,2}):(\d{1,2}):(\d{1,2})/
        hours = $1.strip.to_i
        minutes = $2.strip.to_i
        seconds = $3.strip.to_i

        if hours.to_i == 0
          return sprintf("%02d:%02d", minutes, seconds)
        else
          return sprintf("%01s:%02d:%02d", hours, minutes, seconds)
        end
      elsif duration.match /(\d{1,2})\.(\d{1,2}) s/i
        # in format like: 23.41 s (approx)
        # $1 = 23
        # $2 = 41
        seconds = $1.strip.to_i
        return sprintf("%02d:%02d", 0, seconds)
      end
    end

    def album_artist
      @file_metadata.album_artist
    end

    def title
      @file_metadata.title
    end

    def artist
      @file_metadata.artist
    end

    def album
      @file_metadata.album
    end

    def year
      (@file_metadata.year || @file_metadata.date).to_s
    end

    def genre
      @file_metadata.genre
    end

    def composer
      @file_metadata.composer
    end

    def comment
      comment = @file_metadata.comment
      comment ||= @file_metadata.description
      comment.to_s
    end

  end
end
