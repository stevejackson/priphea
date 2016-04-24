module ImageMetadata
  def self.image_size(filename)
    begin
      metadata = MiniExiftool.new(filename)
      { width: metadata.width, height: metadata.height }
    rescue => e
      { width: nil, height: nil }
    end
  end
end
