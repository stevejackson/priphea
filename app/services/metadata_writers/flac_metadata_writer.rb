class FlacMetadataWriter
  def initialize
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
end
