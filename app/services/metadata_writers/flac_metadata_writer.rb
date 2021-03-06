module MetadataWriters
  class FlacMetadataWriter
    attr_accessor :filename

    def initialize(filename)
      @filename = String(filename)
    end

    def write_cover_art_to_metadata!(cover_art_data, cover_art_file_type)
      mime_type = MimeTypeConverter.from_extension(cover_art_file_type)

      TagLib::FLAC::File.open(@filename) do |file|
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

      tag_name = rename_tag_from_priphea_to_metadata_name(tag_name)

      TagLib::FLAC::File.open(@filename) do |file|
        if %w(album artist comment genre title track year).include?(tag_name)
          file.xiph_comment.send(tag_name + "=", data.to_s)
        else
          file.xiph_comment.send(:add_field, tag_name, data.to_s)
        end
        file.save
      end
    end

    def rename_tag_from_priphea_to_metadata_name(priphea_tag_name)
      case priphea_tag_name
      when 'album_title'
        'album'
      else
        priphea_tag_name
      end
    end
  end
end
