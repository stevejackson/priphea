module MetadataWriters
  class Mp3MetadataWriter
    attr_accessor :filename

    def initialize(filename)
      @filename = String(filename)
    end

    def determine_image_format_mime_type(image_file_type)
      if image_file_type == '.jpg'
        "image/jpeg"
      elsif image_file_type == ".png"
        "image/png"
      end
    end

    def write_cover_art_to_metadata!(cover_art_data, cover_art_file_type)
      mime_type = determine_image_format_mime_type(cover_art_file_type)

      TagLib::MPEG::File.open(@filename) do |file|
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
      tag_name = rename_tag_from_priphea_to_metadata_name(tag_name)

      case tag_name
      when 'comment'
        write_comment_tag(data)
      when 'TPOS' # part of set / disc #
        write_tpos_tag(data)
      when 'TPE2'
        write_tpe2_tag(data)
      else
        write_generic_tag(tag_name, data)
      end
    end

    def open_mp3_file
      TagLib::MPEG::File.open(@filename) do |file|
        tag = file.id3v2_tag(true)
        yield tag
        file.save
      end
    end

    def write_comment_tag(data)
      open_mp3_file do |tag|
        new_frame = true
        if (frame = tag.frame_list('COMM').try(:first))
          new_frame = false
        end
        frame ||= TagLib::ID3v2::CommentsFrame.new
        frame.language = 'eng'
        frame.text = data.to_s
        frame.text_encoding = TagLib::String::UTF8
        tag.add_frame(frame) if new_frame
      end
    end

    def write_tpos_tag(data)
      open_mp3_file do |tag|
        new_frame = true
        if (frame = tag.frame_list('TPOS').try(:first))
          new_frame = false
        end
        frame ||= TagLib::ID3v2::TextIdentificationFrame.new("TPOS", TagLib::String::UTF8)
        frame.text = data.to_s
        tag.add_frame(frame) if new_frame
      end
    end

    def write_tpe2_tag(data)
      open_mp3_file do |tag|
        new_frame = true
        if (frame = tag.frame_list('TPE2').try(:first))
          new_frame = false
        end
        frame ||= TagLib::ID3v2::TextIdentificationFrame.new("TPE2", TagLib::String::UTF8)
        frame.text = data.to_s
        tag.add_frame(frame) if new_frame
      end
    end

    def write_generic_tag(tag_name, data)
      open_mp3_file do |tag|
        tag.send(tag_name + "=", data)
      end
    end

    def rename_tag_from_priphea_to_metadata_name(priphea_tag_name)
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
    end
  end
end
