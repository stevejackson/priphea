require 'rails_helper'

describe MimeTypeConverter do
  def assert_mime_type_conversion(input, expected_result)
    expect(MimeTypeConverter.from_extension(input)).to eq(expected_result)
  end

  describe ".from_extension" do
    it { assert_mime_type_conversion(".jpg", "image/jpeg") }
    it { assert_mime_type_conversion(".jpeg", "image/jpeg") }
    it { assert_mime_type_conversion(".png", "image/png") }

    it "handles uppercase format" do
      assert_mime_type_conversion(".JPG", "image/jpeg")
    end

    it "handles not found case" do
      assert_mime_type_conversion(".abc", nil)
    end
  end
end
