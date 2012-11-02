class Experiment1Controller < ApplicationController
  
  def index
    session['oauth'] = nil
    session['access_token'] = nil
    session['user_id'] = nil
    session['graph'] = nil

    session['oauth'] = Koala::Facebook::OAuth
                        .new(APP_ID, APP_SECRET, SITE_URL + 
                              'experiment1/callback')
    redirect_to session['oauth']
                    .url_for_oauth_code({:permissions => PERMISSIONS})
  end	

  
  def callback
    session['access_token'] = 
              session['oauth'].get_access_token(params[:code])
    redirect_to '/experiment1/pagerank'
  end


  def pagerank

		if not session['access_token']
      redirect_to :root
      return
    end
	
		session['graph'] = Koala::Facebook::API
                          .new(session['access_token'])
		user_info = session['graph']
                    .get_object('me', {:fields => USER_FIELDS})

		if User.find(user_info['id']).nil?
			user_info['friends'] = 
          session['graph'].get_connections("me", "friends")
			logger.debug "Number of Friends #{user_info['friends'].length}"

    	u = User.new
      	user_info.keys.each do |key|
        	m = "#{key}="
        	u.send( m, user_info[key] ) if u.respond_to?( m )
      	end
    	u.save

		else
			logger.debug "\n\nUser already stored\n\n"
		end		 

		@embed_username = user_info['name'].split[0] 
		@embed_logout = '<a href="/home/logout">Logout</a>'
		@embed_back = '<a href="/home/welcome">Back</a>'
	end

end
