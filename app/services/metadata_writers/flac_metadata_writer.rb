class FlacMetadataWriter
  attr_accessor :filename

  def initialize(filename)
    @filename = String(filename)
  end

  def write_cover_art_to_metadata!(filename, cover_art_data, cover_art_file_type)
    mime_type =
      if cover_art_file_type == '.jpg'
        "image/jpeg"
      elsif cover_art_file_type == ".png"
        "image/png"
      end

    TagLib::FLAC::File.open(filename) do |file|
      file.remove_pictures

      pic = TagLib::FLAC::Picture.new
      pic.type = TagLib::FLAC::Picture::FrontCover
      pic.mime_type = mime_type
      pic.description = "Cover"
      pic.data = cover_art_data

      file.add_picture(pic)
      file.save
    end
  end

  def write_tag(tag_name, data)
    return false unless Song::WRITABLE_FIELDS.include? tag_name
    file_extension = AudioMetadata::file_extension(@filename)

    tag_name = AudioMetadata::rename_tag_from_priphea_to_metadata_name(tag_name, file_extension)

    TagLib::FLAC::File.open(@filename) do |file|
      if %w{album artist comment genre title track year}.include?(tag_name)
        file.xiph_comment.send(tag_name + "=", data.to_s)
      else
        file.xiph_comment.send(:add_field, tag_name, data.to_s)
      end
      file.save
    end
  end
end
