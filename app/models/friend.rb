class Friend
  include MongoMapper::EmbeddedDocument

  key :name, String
  key :_id, String

end
