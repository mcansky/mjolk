class Admin::UsersController < ApplicationController
  protect_from_forgery
  before_filter :authenticate_user!
  authorize_resource

  # GET /accounts
  # GET /accounts.xml
  def index
    @accounts = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @accounts }
    end
  end

  # GET /accounts/1
  # GET /accounts/1.xml
  def show
    @account = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @account }
    end
  end

  # GET /accounts/new
  # GET /accounts/new.xml
  def new
    @account = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @account }
    end
  end

  # GET /accounts/1/edit
  def edit
    @account = User.find(params[:id])
  end

  # POST /accounts
  # POST /accounts.xml
  def create
    if (params[:user]["password"] && params[:user]["password_confirmation"]) && (params[:user]["password"].size > 0 && params[:user][:password_confirmation].size > 0) && (params[:user]["password"] == params[:user]["password_confirmation"])
      @account = User.new(:password_confirmation => params[:user][:password_confirmation],
        :password => params[:user][:password],
        :email => params[:user][:email],
        :role => params[:user][:role]
        )
    else
      redirect_to :action => "new"
      return
    end

    respond_to do |format|
      if @account.save
        format.html { redirect_to(:controller => :accounts, :action => :show, :id => @account.id, :notice => 'Account was successfully created.') }
        format.xml  { render :xml => @account, :status => :created, :location => @account }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @account.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /accounts/1
  # PUT /accounts/1.xml
  def update
    @account = User.find(params[:id])
    @account.email = params[:user][:email]
    if (params[:user][:password] && params[:user][:password_confirmation]) && (params[:user][:password].size > 0 && params[:user][:password_confirmation].size > 0) && (params[:user][:password] == params[:user][:password_confirmation])
      @account.password_confirmation = params[:user][:password_confirmation]
      @account.password = params[:user][:password]
    end
    @account.role = params[:user][:role]

    respond_to do |format|
      if @account.save
        format.html { redirect_to( :controller => :accounts, :action => :show, :id => @account.id, :notice => 'Account was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @account.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /accounts/1
  # DELETE /accounts/1.xml
  def destroy
    @account = User.find(params[:id])
    @account.destroy

    respond_to do |format|
      format.html { redirect_to(accounts_url) }
      format.xml  { head :ok }
    end
  end
end