###
#Question C: Recent Likes
###

QUESTION_C = {}

User.all.each {|u|
  q = Question.new
  q.text = "Name 2 recent things that " << u.name << " has liked on Facebook?"
  q.user = u
  q.save

  QUESTION_C[u.id] = q
}


