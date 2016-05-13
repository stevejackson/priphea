class Mp3MetadataWriter
  def initialize
  end

  def write_cover_art_to_metadata!(filename, cover_art_data, cover_art_file_type)
    mime_type =
      if cover_art_file_type == '.jpg'
        "image/jpeg"
      elsif cover_art_file_type == ".png"
        "image/png"
      end

    TagLib::MPEG::File.open(filename) do |file|
      tag = file.id3v2_tag

      # Remove pre-existing art
      tag.frame_list('APIC').each do |frame|
        tag.remove_frame(frame)
      end

      file.save

      # Add attached picture frame
      apic = TagLib::ID3v2::AttachedPictureFrame.new
      apic.mime_type = mime_type
      apic.description = "Cover"
      apic.type = TagLib::ID3v2::AttachedPictureFrame::FrontCover
      apic.picture = cover_art_data

      tag.add_frame(apic)

      file.save
    end
  end
end
