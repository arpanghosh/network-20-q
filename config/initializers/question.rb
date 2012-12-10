##Delete all questions before restarting system

Question.all.each {|q|
  q.destroy
}



