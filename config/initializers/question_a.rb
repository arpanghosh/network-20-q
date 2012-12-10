###
#Question A: Forwarding to the right person
###

QUESTION_A = {}

User.all.each {|u|
  q = Question.new
  q.text = "Are you " << u.name << " ? If yes, then answer this question with yes. Else try and forward it to " << u.name << " ."
  q.save

 QUESTION_A[u.id] = q
}


