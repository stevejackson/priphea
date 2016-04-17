module MetadataExtractors
  class Mp3MetadataExtractor < AbstractMetadataExtractor

    def track_number
      track_number_string = @file_metadata.track.to_s
      if (index = track_number_string.index('/'))
        track_number_string[0, index].try(:to_i)
      else
        track_number_string.try(:to_i)
      end
    end

    # mp3's track number metadata is sometimes in format like: 1/33
    # convert this to 33
    def total_tracks
      track_number_string = @file_metadata.track.to_s
      if (index = track_number_string.index('/'))
        track_number_string[index + 1, track_number_string.length]
      else
        track_number_string
      end
    end

    # disc number (part of set) sometimes formatted like: 1/2
    # convert this to 1
    def disc_number
      disc_number_string = @file_metadata.part_of_set.to_s
      if disc_number_string && (index = disc_number_string.index('/'))
        disc_number_string[0, index].try(:to_i)
      else
        disc_number_string.try(:to_i)
      end
    end

    def total_discs
      disc_number_string = @file_metadata.part_of_set.to_s

      if disc_number_string && disc_number_string.is_a?(String) && (index = disc_number_string.index('/'))
        disc_number_string[index + 1, disc_number_string.length]
      else
        nil
      end
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
      @file_metadata.band
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
      @file_metadata.year.to_s
    end

    def genre
      @file_metadata.genre
    end

    def composer
      @file_metadata.composer
    end

    def comment
      @file_metadata.comment
    end

  end
end
