class Question
  include MongoMapper::Document

  key :text, String
  many  :answers
  many  :suggestions

	timestamps!

end
