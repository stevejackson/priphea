class MimeTypeConverter
  class UnsupportedFormatException < StandardError; end

  EXTENSION_TO_MIME_TYPE_MAPPING = {
    ".jpg" => "image/jpeg",
    ".jpeg" => "image/jpeg",
    ".png" => "image/png"
  }.freeze

  def self.from_extension(extension)
    EXTENSION_TO_MIME_TYPE_MAPPING[extension.downcase]
  end
end
