class Admin::UsersController < ApplicationController
  protect_from_forgery
  before_filter :authenticate_user!
  authorize_resource

  # GET /users
  # GET /users.xml
  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.xml
  def create
    if (params[:user]["password"] && params[:user]["password_confirmation"]) && (params[:user]["password"].size > 0 && params[:user][:password_confirmation].size > 0) && (params[:user]["password"] == params[:user]["password_confirmation"])
      @user = User.new(:password_confirmation => params[:user][:password_confirmation],
        :password => params[:user][:password],
        :email => params[:user][:email],
        :roles => params[:user][:roles]
        )
    else
      redirect_to :action => "new"
      return
    end

    respond_to do |format|
      if @user.save
        format.html { redirect_to(:controller => :users, :action => :show, :id => @user.id, :notice => 'Account was successfully created.') }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])
    @user.email = params[:user][:email]
    if (params[:user][:password] && params[:user][:password_confirmation]) && (params[:user][:password].size > 0 && params[:user][:password_confirmation].size > 0) && (params[:user][:password] == params[:user][:password_confirmation])
      @user.password_confirmation = params[:user][:password_confirmation]
      @user.password = params[:user][:password]
    end
    @user.roles = params[:user][:roles]

    respond_to do |format|
      if @user.save
        format.html { redirect_to( :controller => :users, :action => :show, :id => @user.id, :notice => 'Account was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end

  def mass_mail
  end
  
  def mass_email_send
    General.mass_email(params[:text], params[:role]).deliver
    redirect_to :action => :index
  end
end