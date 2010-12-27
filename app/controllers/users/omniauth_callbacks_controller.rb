class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def twitter
    # You need to implement the method below in your model
    logger.info(env["omniauth.auth"].inspect)
    @user = User.find_for_twitter_oauth(env["omniauth.auth"], current_user)
    if !@user
      @user = User.new(:name => env["omniauth.auth"])
      render "sign_up" and return
    elsif @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Twitter"
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.twitter_data"] = env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end

  def create
    user = User.new(:name => params[:name], :email => params[:email], :password => params[:password], :password_confirmation => params[:password_confirmation])
    user.save
    redirect_to :controller => "posts"
  end
end
