FactoryGirl.define do
  factory :song, aliases: [:active_song] do
    album
    state "active"
  end
end
