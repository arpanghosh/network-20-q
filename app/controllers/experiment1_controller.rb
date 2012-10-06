class Experiment1Controller < ApplicationController
  
	def index
		if not session['access_token']
      redirect_to :root
      return
    end
	
		session['graph'] = Koala::Facebook::API.new(session['access_token'])
		user_info = session['graph'].get_object('me', {:fields => USER_FIELDS})

		if User.find(user_info['id']).nil?

			user_info['friends'] = session['graph'].get_connections("me", "friends")
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
