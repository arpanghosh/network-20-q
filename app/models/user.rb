class User
  include MongoMapper::Document

  key :_id, String
  key :name, String
  key :age, Integer
  key :gender, String
  key :coursera, Boolean, :default => false

	key :friends, Array
  key :friends_in_class, Array

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
