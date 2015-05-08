module ImageMetadata
  def self.image_size(filename)
    metadata = MiniExiftool.new(filename)
    { width: metadata.width, height: metadata.height }
  end
end
