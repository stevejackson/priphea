class Mp3MetadataWriter
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

  def write_tag(tag_name, data)
    return false unless Song::WRITABLE_FIELDS.include? tag_name
    file_extension = AudioMetadata::file_extension(@filename)

    tag_name = AudioMetadata::rename_tag_from_priphea_to_metadata_name(tag_name, file_extension)

    TagLib::MPEG::File.open(@filename) do |file|
      tag = file.id3v2_tag(true)
      case tag_name
      when 'comment'
        new_frame = true
        if (frame = tag.frame_list('COMM').try(:first))
          new_frame = false
        end
        frame ||= TagLib::ID3v2::CommentsFrame.new
        frame.language = 'eng'
        frame.text = data.to_s
        frame.text_encoding = TagLib::String::UTF8
        tag.add_frame(frame) if new_frame
      when 'TPOS' # part of set / disc #
        new_frame = true
        if (frame = tag.frame_list('TPOS').try(:first))
          new_frame = false
        end
        frame ||= TagLib::ID3v2::TextIdentificationFrame.new("TPOS", TagLib::String::UTF8)
        frame.text = data.to_s
        tag.add_frame(frame) if new_frame
      when 'TPE2'
        new_frame = true
        if (frame = tag.frame_list('TPE2').try(:first))
          new_frame = false
        end
        frame ||= TagLib::ID3v2::TextIdentificationFrame.new("TPE2", TagLib::String::UTF8)
        frame.text = data.to_s
        tag.add_frame(frame) if new_frame
      else
        tag.send(tag_name + "=", data)
      end
      file.save
    end
  end
end
