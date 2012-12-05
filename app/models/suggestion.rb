class Suggestion
  include MongoMapper::Document

  key :suggestee, String
  
  belongs_to  :question
  belongs_to  :user

	timestamps!

end
