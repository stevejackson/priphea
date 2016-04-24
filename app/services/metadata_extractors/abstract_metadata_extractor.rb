require 'taglib'

module MetadataExtractors
  class AbstractMetadataExtractor
    attr_accessor :filename
    attr_accessor :file_extension
    attr_accessor :file_metadata

    def initialize(filename)
      @filename = filename
      @file_extension = AudioMetadata::file_extension(@filename)
      read_file_metadata
    end

    def read_file_metadata
      @file_metadata = MiniExiftool.new(@filename)
    end

    # should be implemented by child class
    def create_metadata_hash
      metadata = {}

      metadata['track_number'] = track_number
      metadata['total_tracks'] = total_tracks
      metadata['disc_number'] = disc_number
      metadata['total_discs'] = total_discs
      metadata['duration'] = duration
      metadata['album_artist'] = album_artist
      metadata['title'] = title
      metadata['artist'] = artist
      metadata['album'] = album
      metadata['year'] = year
      metadata['genre'] = genre
      metadata['composer'] = composer
      metadata['comment'] = comment

      metadata['filesize'] = filesize
      metadata['filetype'] = filetype

      metadata
    end

    def track_number; end
    def disc_number; end
    def total_tracks; end
    def total_discs; end
    def duration; end
    def album_artist; end
    def title; end
    def artist; end
    def album; end
    def year; end
    def genre; end
    def composer; end
    def comment; end

    def filesize
      File.size(@filename).to_s
    end

    def filetype
      @file_extension
    end
  end
end
