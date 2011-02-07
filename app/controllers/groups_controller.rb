class GroupsController < ApplicationController
  before_filter :authenticate_user!, :except => ["index", "show"]
  authorize_resource :class => "Group"
  cache_sweeper :group_sweeper

  def index
    groups = nil
    if params[:username]
      @user = User.find_by_name(params[:username])
      groups = @user.groups
    else
      groups = Group.all
    end
    @groups = groups.paginate(:page => params[:page])
  end

  def show
    @group = Group.find(params[:id])
    bookmarks = Bookmark.find(:all, :conditions => ['private = 0 AND user_id in (?)', @group.users_id])
    @bookmarks = bookmarks.paginate(:page => params[:page])
  end

  def new
    @group = Group.new
  end

  def create
    @group = Group.new
    @group.name = params[:group][:name]
    @group.desc = params[:group][:desc]
    @group.owner = current_user
    @group.users << current_user
    if @group.save
      redirect_to :action => :show, :id => @group.id
      return
    else
      redirect_to :action => :new, :alert => "could not create the group"
      return
    end
  end

  def destroy
    group = Group.find(params[:id])
    if current_user == group.owner
      group.destroy
    else
      redirect_to :action => :show, :id => group.id, :alert => "you don't have rights to do that"
      return
    end
    redirect_to :action => :index
  end

  def edit
    @group = Group.find(params[:id])
    if not (@group.owner == current_user)
      redirect_to :action => :show, :id => @group.id, :alert => "tou don't have rights to do that"
    end
  end

  def update
    group = Group.find(params[:id])
    if not (@group.owner == current_user)
      redirect_to :action => :show, :id => @group.id, :alert => "tou don't have rights to do that"
    end
    group.name = params[:group][:name]
    group.desc = params[:group][:desc]
    if group.save
      redirect_to :action => :show, :id => group.id, :notice => "Successfully updated"
      return
    else
      redirect_to :action => :edit, :id => group.id, :notice => "Could not update the group"
    end
  end
end