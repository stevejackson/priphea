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
      MetadataWriters::Mp3MetadataWriter.new(@filename)
    when '.flac'
      MetadataWriters::FlacMetadataWriter.new(@filename)
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
end
