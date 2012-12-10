class User
  include MongoMapper::Document

  key :_id, String
  key :name, String
  key :age, Integer
  key :gender, String
  key :coursera, Boolean, :default => false
  key :present, Boolean, :default => false
  key :major, String

	key :facebook_friends, Array
  key :facebook_friends_in_class, Array

  key :question_queue, Array

  many  :questions
  many  :answers
  many  :suggestions
  
	timestamps!


	def birthday=(bdayString)
  	self[:age] = 
        Integer(Date.today - Date.strptime(bdayString, "%m/%d/%Y"))/365
	end


	def id=(idString)
		self[:_id] = idString
	end


end
