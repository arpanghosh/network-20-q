class HomeController < ApplicationController

  def index
  end


	def login
    session['oauth'] = nil
    session['access_token'] = nil
    session['user_id'] = nil
    session['graph'] = nil

    session['oauth'] = Koala::Facebook::OAuth.new(APP_ID, APP_SECRET, SITE_URL + 'home/callback')
    redirect_to session['oauth'].url_for_oauth_code({:permissions => PERMISSIONS})
  end


	def callback
    session['access_token'] = session['oauth'].get_access_token(params[:code])
    redirect_to '/home/welcome'
	end


	def welcome
		if not session['access_token']
      redirect_to :root
      return
    end

		@embed_logout = '<a href="logout">Logout</a>'
	end


	def logout
    if not session['access_token']
      redirect_to :root
      return
    end

    logout_url = "https://www.facebook.com/logout.php?next="+SITE_URL+"&access_token="+session['access_token']
    session['oauth'] = nil
    session['access_token'] = nil
    session['user_id'] = nil
    session['graph'] = nil

    redirect_to logout_url
  end



end
