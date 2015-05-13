class FileNotification
  include Mongoid::Document

  field :path, type: String
  field :event_type, type: String
end
