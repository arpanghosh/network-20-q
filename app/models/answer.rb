class Answer
  include MongoMapper::Document

  key :text, String
  key :correct, Boolean
  
  belongs_to  :user
  belongs_to  :question

	timestamps!

end
