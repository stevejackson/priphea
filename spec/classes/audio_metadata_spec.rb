require 'rails_helper'

describe AudioMetadata do
  describe "duration" do
    it "should work for format 1:02:43" do
      input = "1:02:43"

      result = AudioMetadata::mp3_duration(input)

      expect(result).to eq("1:02:43")
    end

    it "should work for format 0:02:43" do
      input = "0:02:43"

      result = AudioMetadata::mp3_duration(input)

      expect(result).to eq("02:43")
    end

    it "should work for format 42.01 s" do
      input = "42.01 s"

      result = AudioMetadata::mp3_duration(input)

      expect(result).to eq("00:42")
    end
  end
end
