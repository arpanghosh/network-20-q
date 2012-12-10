###
#Question B: Name 5 professors in a department
###

QUESTION_B = {}
MAJORS = ["computer science", "electrical engineering", "economics", "political science"]

MAJORS.each {|m|
  q = Question.new
  q.text = "Name 5 professors in the " + m + " department."
  q.save
  
  QUESTION_B[m] = q
}   


