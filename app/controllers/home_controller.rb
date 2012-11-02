class HomeController < ApplicationController

  def index
  end

	def welcome
		@embed_logout = '<a href="back">Back</a>'
	end


	def back
    redirect_to :root
  end



end
