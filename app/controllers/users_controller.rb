class UsersController < ApplicationController
  protect_from_forgery
  # auth needed !x
  before_filter :authenticate_user!
  def follow
    user = User.find(params[:id])
    if (request.request_method == :post) || (params[:method] == "post")
      # oh my current user wants to follow User.find(params[:id])
      current_user.followed << user
      logger.info("#{current_user.name} follows #{user.name}")
    elsif (request.request_method == :delete) || (params[:method] == "delete")
      # oh my current_user wants to stop following User.find(params[:id])
      current_user.followed.delete(user)
      logger.info("#{current_user.name} stop following #{user.name}")
    end
    user.save
    redirect_to :controller => :posts, :action => :index, :username => user.name
  end
end