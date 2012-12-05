class Question
  include MongoMapper::Document

  key :text, String
  key :answer, String  

  belongs_to   :user
  many  :answers
  many  :suggestions

	timestamps!

end
