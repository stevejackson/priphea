require 'rails_helper'

describe FileNotificationProcessor do

  it "should be able to create a new song file when added" do
    fn = FileNotification.new
    fn.event_type = 'addition'
    fn.path = File.join(Rails.root, "spec", "data", "embedded-art.flac")
    fn.save!

    FileNotificationProcessor::process!

    expect(Song.count).to eq(1)
    expect(Song.first.state).to eq("active")
  end

end
