###
#Question D: Questions in their field
###

QUESTION_D = {}
questions = [{"q" => "Which political figure proposed the idea of Tyranny of the Majority in 1788?", 
              "m" => "political science"},
             {"q" => "Which economist wrote The General Theory of Employment, Interest and Money?", 
              "m" => "economics"},
             {"q" => "What is the Knuth-Morris-Pratt algorithm used for?     a)sorting     b)shuffling     c)sub-string search     d)shortest path.", 
              "m" => "computer science"},
             {"q" => "On a pole-zero diagram, where do the poles need to be to indicate a stable system?\     a)left of the jw axis     b)above the sigma axis     c)below the sigma axis     d)right of the jw axis.", 
              "m" => "electrical engineering"}]


questions.each {|ques|
  q = Question.new
  q.text = ques["q"]
  q.save
  
  QUESTION_D[ques["m"]] = q
}   


