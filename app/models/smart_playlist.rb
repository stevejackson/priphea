class SmartPlaylist
  include Mongoid::Document

  field :name, type: String
  field :mongoid_query, type: String
  field :shuffle_on_load, type: Boolean

  def as_json(*args)
    res = super

    res["id"] = res.delete("_id").to_s

    res
  end

  def as_json_with_songs(*args)
    res = as_json

    res["id"] = res.delete("_id").to_s

    if self.shuffle_on_load
      songs = Song.for_js(self.mongoid_query).sort_by { rand }.as_json
    else
      songs = Song.for_js(self.mongoid_query).as_json
    end

    res["songs"] = songs

    res
  end
end
