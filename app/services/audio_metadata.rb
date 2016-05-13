require 'forwardable'

class AudioMetadata
  extend Forwardable

  attr_accessor :filename

  attr_accessor :metadata_writer
  delegate [:write_cover_art_to_metadata!, :write_tag] => :metadata_writer

  def initialize(filename)
    @filename = String(filename)
    extension = File.extname(@filename).downcase

    @metadata_writer = case extension
    when '.mp3'
      Mp3MetadataWriter.new(@filename)
    when '.flac'
      FlacMetadataWriter.new(@filename)
    end
  end

  def self.file_extension(filename)
    File.extname(filename).downcase
  end

  def metadata_hash
    file_extension = AudioMetadata::file_extension(filename)

    extractor =
      case file_extension
      when ".mp3"
        MetadataExtractors::Mp3MetadataExtractor.new(filename)
      when ".flac"
        MetadataExtractors::FlacMetadataExtractor.new(filename)
      else
        raise "Unsupported file type"
      end

    metadata = extractor.create_metadata_hash
    metadata
  end

  def self.generate_priphea_id_comment(existing_comment, song)
    result = existing_comment || ""
    result.gsub!(/\[PRIPHEA-ID-(.{24})\]/, '')
    result << "[PRIPHEA-ID-#{song.id}]"
    result
  end

  def self.extract_priphea_id_from_comment(existing_comment)
    return nil unless existing_comment.present?

    existing_comment.match /\[PRIPHEA-ID-(.{24})\]/
    $1
  end

  # if track number is stored in priphea db as "track_number", in mp3 id3v2 it's named "track".
  # this method turns "track_number" into "track".

  # some example of an id3v2 data set:
  # - ["TIT2 Sea-Cat Walkway [Boy Meets Girl]", "TPE1 arc", "TRCK 1/0", "TALB Sea-Cat Walkway - Mother Arrange+Original Album", "TPOS 0/0", "TDRC 2006", "TCON 同ﾺ", "APIC [image/jpeg]", "POPM no@email rating=255 counter=0", "TBPM 0", "TCMP 0", "TDOR 0000", "TPE2 arc", "UFID ", "USLT "]
  def self::rename_tag_from_priphea_to_metadata_name(priphea_tag_name, extension)
    if extension == '.mp3'
      case priphea_tag_name
        when 'track_number'
          'track'
        when 'disc_number'
          'TPOS' # part of set frame
        when 'album_artist'
          'TPE2'
        when 'album_title'
          'album'
        else
          priphea_tag_name
      end
    else
      case priphea_tag_name
        when 'album_title'
          'album'
        else
          priphea_tag_name
      end
    end
  end

end
