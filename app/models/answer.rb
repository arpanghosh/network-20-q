class Answer
  include MongoMapper::Document

  key :text, String
  
  belongs_to  :user
  belongs_to  :question

	timestamps!

end
