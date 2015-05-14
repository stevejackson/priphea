class SmartPlaylist
  include Mongoid::Document

  field :name, type: String
  field :mongoid_query, type: String
  field :shuffle_on_load, type: Boolean
  field :song_limit, type: Integer

  def as_json(*args)
    res = super

    res["id"] = res.delete("_id").to_s

    res
  end

  def as_json_with_songs(*args)
    res = as_json

    res["id"] = res.delete("_id").to_s

    if self.shuffle_on_load
      if self.song_limit
        songs = Song.active.for_js(self.mongoid_query).sort_by { rand }.first(self.song_limit)
      else
        songs = Song.active.for_js(self.mongoid_query).sort_by { rand }
      end
    else
      if self.song_limit
        songs = Song.active.for_js(self.mongoid_query).limit(self.song_limit)
      else
        songs = Song.active.for_js(self.mongoid_query)
      end
    end

    songs = songs.as_json

    res["songs"] = songs

    res
  end
end
