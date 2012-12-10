class Experiment2Controller < ApplicationController
  
  def index
    session['oauth'] = nil
    session['access_token'] = nil
    session['user_id'] = nil
    session['graph'] = nil

    session['oauth'] = 
        Koala::Facebook::OAuth.new(APP_ID, APP_SECRET, SITE_URL + 
                                                  'experiment2/callback')
    redirect_to session['oauth']
                    .url_for_oauth_code({:permissions => PERMISSIONS})
  end	

  
  def callback
    session['access_token'] = 
          session['oauth'].get_access_token(params[:code])
    redirect_to '/experiment2/dashboard'
  end


  def submit_major
    if not session['access_token']
      redirect_to :root
      return
    end
  
    u = User.find(session['user_id'])
    u.present = true
    u.major = params["major"]["name"]
    u.save 
    
    redirect_to :action => 'go'
  end   


  def dashboard
		if not session['access_token']
      redirect_to :root
      return
    end

    if not session['user_id']	
		  session['graph'] = 
          Koala::Facebook::API.new(session['access_token'])
		  user_info = 
          session['graph'].get_object('me', {:fields => USER_FIELDS})
      session['user_id'] = user_info['id']
      add_new_user(user_info)
    end

    @user = User.find(session['user_id'])
		@embed_logout = '<a href="/experiment2/logout">Logout</a>'
	end


  def go
    if not session['access_token']
      redirect_to :root
      return
    end

    @user = User.find(session['user_id'])
    @embed_logout = '<a href="/experiment2/logout">Logout</a>'
  end
 

  def forwardees_and_questions
    if not session['access_token']
      redirect_to :root
      return
    end

    @user = User.find(session['user_id'])

    other_classmates = (User.all.map {|u| {"name" => u.name, "id" => u.id}} - 
                       [{"name" => @user.name, "id" => @user.id}] - @user.facebook_friends)

    if other_classmates.length > 0
      random_classmate = [other_classmates.sample()]
    else
      random_classmate = []
    end

    #@user.facebook_friends_in_class = (User.all.select{|u| u.present == true }.map {|u| {"name" => u.name, "id" => u.id}} &
    #                                   @user.facebook_friends) + random_classmate
    @user.facebook_friends_in_class = (User.all.map {|u| {"name" => u.name, "id" => u.id}} &
                                       @user.facebook_friends) + random_classmate       
    generate_questions(@user)      
    @user.save

    redirect_to :action => 'question'
  end
 

  def generate_questions(user)
    user.question_queue = []
    rng = Random.new(Time.now.nsec) 
    
    #Other users whose questions are to be given to this user  
    #other_users = User.all.select{|u| u.present == true }.map{|u| u.id } - [user.id]
    other_users = User.all.map{|u| u.id } - [user.id]

    #Other majors whose questions are to be given to this user
    other_majors = MAJORS - [user.major]

    ##Question A
    user.question_queue << QUESTION_A[other_users[rng.rand(other_users.length)]]._id.to_s

    ##Question B
    user.question_queue << QUESTION_B[other_majors[rng.rand(other_majors.length)]]._id.to_s
    
    ##Question C
    user.question_queue << QUESTION_C[other_users[rng.rand(other_users.length)]]._id.to_s

    ##Question D
    user.question_queue << QUESTION_D[other_majors[rng.rand(other_majors.length)]]._id.to_s  
  end  

  
  def question
    if not session['access_token']
      redirect_to :root
      return
    end 
 
    @user = User.find(session['user_id'])
    
    if params['qid']
      qid = params['qid']
    else
      tackled = Set.new
      tackled.merge(@user.answers.map{|a| a.question._id.to_s} + @user.suggestions.map{|s| s.question._id.to_s})
      while true
        qid = @user.question_queue.last
        break if ((not tackled.include?(qid)) or (not qid))
        @user.question_queue.delete(qid)
      end
    end

    if qid 
      @question = Question.find(qid)
      @forwarders = @question.suggestions
                    .select {|s| s.suggestee == session['user_id']}
                    .map{|s| s.user.name}
    else
      @question = nil
    end
    
    @user.save

    @embed_logout = '<a href="/experiment2/logout">Logout</a>'
  end


=begin
  def add_question
    if not session['access_token']
      redirect_to :root
      return
    end

    @user = User.find(session['user_id'])
  end

  
  def submit_question
    if not session['access_token']
      redirect_to :root
      return
    end

    if params['question']['text'].length > 0 && params['question']['answer'].length > 0
      q = Question.new
      q.text = params['question']['text']
      q.answer = params['question']['answer']
      q.user = User.find(session['user_id'])
      q.save
    
      if q.user.questions.count == 5
        redirect_to :action => 'dashboard'
      else
        redirect_to :action => 'add_question', :error => 'false'
      end

    else
      redirect_to :action => 'add_question', :error => 'true'
    end
  end
=end

  
  def logout
    if not session['access_token']
      redirect_to :root
      return
    end

    logout_url = "https://www.facebook.com/logout.php?next=" + 
        SITE_URL  + "&access_token=" + session['access_token']
    session['oauth'] = nil
    session['access_token'] = nil
    session['user_id'] = nil
    session['graph'] = nil

    redirect_to logout_url
  end

  
  def add_new_user(user_info)
    if User.find(user_info['id']).nil?
      user_info['facebook_friends'] = session['graph']
                                .get_connections("me", "friends")
      #logger.debug "\n\nNumber of Friends #{user_info['facebook_friends'].length}\n\n"

      u = User.new
      user_info.keys.each do |key|
        m = "#{key}="
        u.send( m, user_info[key] ) if u.respond_to?( m )
      end
      u.save
    else
      #logger.debug "\n\nUser already stored\n\n"
    end    
  end


=begin
  def dashboard_question(user)
    questions = Question.all -
                user.questions - 
                user.answers.map {|a| a.question } -
                user.suggestions.map {|s| s.question}

    suggestions_for_me = Suggestion.all.select {|s| s.suggestee == session['user_id']}
    grouping_suggestions = {}
    suggestions_for_me.each do |s|
      if grouping_suggestions.has_key?(s.question._id.to_s)
        grouping_suggestions[s.question._id.to_s] = grouping_suggestions[s.question._id.to_s] + [s.user.name]
      else
        grouping_suggestions[s.question._id.to_s] = [s.user.name]
      end
    end

    questions.each do |q| 
      q['suggesters'] = grouping_suggestions[q._id.to_s]
    end
  
    return questions.sort { |q1,q2| q1.updated_at <=> q2.updated_at }.reverse
  end
=end


  def answer_question
    if not session['access_token']
      redirect_to :root
      return
    end

    @embed_back = '<a href="/experiment2/question?qid=' + params['qid'] + '">Back to the question</a>'
  end


  def submit_answer
    if not session['access_token']
      redirect_to :root
      return
    end

    if params['answer']['text'].length > 0
      a = Answer.new
      a.text = params['answer']['text']
      a.question = Question.find(params['qid'])
      a.user = User.find(session['user_id'])
      a.save

      u = User.find(session['user_id'])
      u.question_queue.delete(params['qid'])
      u.save

      redirect_to :action => 'question'
    else
      redirect_to :action => 'answer_question', 
                  :error => 'true', 
                  :qid => params['qid']
    end
  end


  def forward_question
    if not session['access_token']
      redirect_to :root
      return
    end

    already_forwarded = Question.find(params['qid']).suggestions
                          .select {|s| s.suggestee == session['user_id']}
                          .map{|s| {"name" => s.user.name, "id" => s.user.id}}
    @potential_forwardees = User.find(session['user_id']).facebook_friends_in_class - already_forwarded
    @embed_back = '<a href="/experiment2/question?qid=' + params['qid'] + '">Back to the question</a>'
  end

  
  def submit_forward
    if not session['access_token']
      redirect_to :root
      return
    end

    forwardee = params['forwardee']['id']
    s = Suggestion.new
    s.suggestee = forwardee
    s.question = Question.find(params['qid'])
    s.user = User.find(session['user_id'])
    s.save

    u = User.find(forwardee)
    u.question_queue << s.question._id.to_s
    u.save

    me = User.find(session['user_id'])
    me.question_queue.delete(params['qid'])
    me.save

    redirect_to "/experiment2/question"
  end


end
