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

    @question_to_display = [] #dashboard_question(u)
		@embed_logout = '<a href="/experiment2/logout">Logout</a>'
	end


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
      logger.debug "\n\nNumber of Friends #{user_info['facebook_friends'].length}\n\n"

      u = User.new
      user_info.keys.each do |key|
        m = "#{key}="
        u.send( m, user_info[key] ) if u.respond_to?( m )
      end
      #u.facebook_friends_in_class = (User.all.map {|u| {"name" => u.name, "id" => u.id}} &
      #                        User.find(session['user_id']).facebook_friends)
      u.save
    else
      logger.debug "\n\nUser already stored\n\n"
    end    
  end


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


  def answer_question
    if not session['access_token']
      redirect_to :root
      return
    end
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
      redirect_to :action => 'dashboard'
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

    @potential_forwardees = User.find(session['user_id']).friends_in_class
  end

  
  def submit_forward
    if not session['access_token']
      redirect_to :root
      return
    end

    forwardees = params['id'].select{|k,v| v == "1"}.keys
    forwardees.each do |fw|
      s = Suggestion.new
      s.suggestee = fw
      s.question = Question.find(params['qid'])
      s.user = User.find(session['user_id'])
      s.save  
    end   
    redirect_to "/experiment2/dashboard"
  end


end
