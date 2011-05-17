require 'xmlsimple'
require 'net/http'
require "net/https"
require 'uri'
require 'json'

class PostsController < ApplicationController
  protect_from_forgery
  # auth needed !x
  before_filter :authenticate_user!, :except => "index"
  authorize_resource :class => "Bookmark"
  
  def index
    response.headers['Cache-Control'] = 'public, max-age=240'
    # testing some params
    user = nil
    if params[:username]
      user = User.find_by_name(params[:username])
      if user == nil
        redirect_to :controller => :application, :action => :index, :notice => "User not found"
        return
      end
    end
    # building conditions
    conditions = Array.new
    conditions[0] = ""
    if params[:username]
      # filter private ones
      conditions[0] += "private = ?"
      conditions << 0
    elsif params[:all_users]
      user = nil
    elsif current_user
      user = current_user
    elsif (!current_user && !params[:username] && !params[:all_users])
      redirect_to :controller => :application, :action => :index
    end
    if params[:tag]
      limit = "ALL"
      if ActiveRecord::Base.connection.class.to_s.split('::')[-1].gsub("Adapter",'') == "SQLite3"
        limit = -1
      end
      if user
        if limit == ("ALL" || -1)
          posts = user.bookmarks.tagged_with(params[:tag]).find(:all, :offset => (params[:start] || 0), :conditions => conditions, :order => "bookmarked_at DESC")
        else
          posts = user.bookmarks.tagged_with(params[:tag]).find(:all, :offset => (params[:start] || 0), :limit => (params[:results] || limit), :conditions => conditions, :order => "bookmarked_at DESC")
        end
      else
        if limit == ("ALL" || -1)
          posts = Bookmark.tagged_with(params[:tag]).find(:all, :offset => (params[:start] || 0), :conditions => conditions, :order => "bookmarked_at DESC")
        else
          posts = Bookmark.tagged_with(params[:tag]).find(:all, :offset => (params[:start] || 0), :limit => (params[:results] || limit), :conditions => conditions, :order => "bookmarked_at DESC")
        end
      end
    else
      if user
        if !params[:result]
          posts = user.bookmarks.find(:all, :offset => (params[:start] || 0), :conditions => conditions, :order => "bookmarked_at DESC")
        else
          posts = user.bookmarks.find(:all, :offset => (params[:start] || 0), :limit => (params[:results] || limit), :conditions => conditions, :order => "bookmarked_at DESC")
        end
      else
        if !params[:result]
          posts = Bookmark.find(:all, :offset => (params[:start] || 0), :conditions => conditions, :order => "bookmarked_at DESC")
        else
          posts = Bookmark.find(:all, :offset => (params[:start] || 0), :limit => (params[:results] || limit), :conditions => conditions, :order => "bookmarked_at DESC")
        end
      end
    end
    # filter private ones
    the_posts = Array.new
    posts.each do |post|
      if post.private?
        if current_user
          the_posts << post if (post.user == current_user)
        end
      else
        the_posts << post
      end
    end
    @user = user
    if user
      @tags = user.bookmarks.tag_counts_on(:tags) unless params[:tag]
    end
    @posts_count = the_posts.size
    @posts = the_posts.paginate(:page => params[:page])
  end

  def new
    @bookmark = Bookmark.new
  end

  def tag_cloud
    @tags = Post.tag_counts_on(:tags)
  end

  # also respond to posts/add
  # implemented : url (req), description (req), tags, dt, shared
  # not implemented : replace, extended
  # can also be used to clone/copy a bookmark if id is passed
  def create
    incomplete = true
    error = false
    if ((params[:url] != nil) &&( (params[:description] != nil ) || (params[:bookmark]["title"] != nil )))
      incomplete = false
      url = nil
      if params[:url][:url]
        url = params[:url][:url]
      else
        url = params[:url]
      end
      if not ((url =~ /^http:\/\//) || (url =~ /^https:\/\//))
        url = "http://" + url
      end
      link = nil
      if (url =~ /goo\.gl/)
        link = get_link_from_short(url)
      else
        link = Link.find_by_url(url) || Link.new(:url => url)
      end
      link.save
      if link.users.include?(current_user)
        redirect_to :action => "index", :notice => "Already in !"
        return
      else
        datetime = nil
        datetime = params[:dt] if params[:dt]
        comment = params[:extended] || params[:bookmark][:comment] || nil
        description = params['description'] || params[:bookmark]['title']

        new_bookmark = Bookmark.new(:title => description, :comment => comment, :link_id => link.id, :user_id => current_user.id, :bookmarked_at => (datetime || Time.now))
        new_bookmark.private = 1 if ((params[:shared] && (params[:shared] == "no")))
        new_bookmark.private = params[:bookmark]["private"] if params[:bookmark]["private"]
        new_bookmark.tag_list = params['tags'] || params[:bookmark]['tags']
        current_user.bookmarks_update_at = Time.now
        if new_bookmark.save
          current_user.save
          logger.info("bookmark for #{url} added")
        else
          error = true
          logger.warn("Error : could not save the new bookmark")
        end
      end
    elsif params[:id]
      incomplete = false
      # clone
      to_clone = Bookmark.find(params[:id])
      if to_clone == nil
        redirect_to root_url, :alert => "not found !"
        return
      end
      # check if the link is already associated with 
      if to_clone.link.users.include?(current_user)
        redirect_to :action => "index", :notice => "Already in !"
        return
      end
      new_b = to_clone.clone
      new_b.user = current_user
      new_b.tag_list = to_clone.tag_list
      new_b.bookmarked_at = Time.now
      if new_b.save
        current_user.save
        logger.info("bookmark for #{new_b.link.url} cloned")
      end
      redirect_to :action => "index", :username => to_clone.user.name
      return
    end
    if incomplete || error
      flash[:error] = "incomplet"
      render :file => File.join(Rails.root, 'public', '400.html'), :status => 400
    else
      redirect_to :action => "index", :notice => "Added properly !"
    end
  end

  def destroy
    error = false
    if params[:url] || params[:id]
      if params[:url]
        link = Bookmark.find_by_url(url) || nil
        if (link && link.users.include(current_user))
          bookmark = current_user.bookmarks.find(:all, :conditions => ["link_id = ?", link.id])
          bookmark.destroy
          link.destroy if link.bookmarks.size == 0 # destroy the link if no bookmarks are left
        end
      elsif params[:id]
        bookmark = Bookmark.find(params[:id]) || nil
        link = bookmark.link
        bookmark.destroy if bookmark.user == current_user
        link.destroy if link.bookmarks.size == 0 # destroy the link if no bookmarks are left
      end
    end
    redirect_to :action => "index"
  end

  # to fix
  def import_file
    if params[:file]
      # using hpricot to read
      xml_stuff = nil
      begin
        xml_stuff = Hpricot(params[:file])
      rescue
        logger.info("Hpricot doesn't like this. this is not xml")
      end
      if xml_stuff
        if (((xml_stuff/"posts") != nil) && ((xml_stuff/"posts").size > 0)) # hooray delicious format ?
          (xml_stuff/"posts").each do |post|
            
            # let's check if the url is already in the db
            # but first we need to check if there is http:// in there
            url = post["href"]
            if ((post["href"] =~ /^http:\/\//) || (post["href"] =~ /^https:\/\//))
            else
              url = "http://" + post["href"]
            end
            link = Link.find_by_url(url) || nil
            # not found must create
            if !link
              link = Link.new(:url => url)
            end


            # now taking care of the bookmark
            if link.users.include?(current_user)
              # already in
            else
              new_bookmark = Bookmark.new(:title => post['description'], :link => link)
              new_bookmark.tag_list = post['tag'].gsub(" ",", ")
              current_user.bookmarks << new_bookmark
              new_bookmark.save
            end 
          end
        end
      end
      redirect_to :action => 'index'
    else
      redirect_to :action => 'import'
    end
  end

  def edit
    @bookmark = Bookmark.find(params[:id])
  end

  def import
    
  end

  def import_url
    if (params[:password] && params[:username])
      current_user.import_from_delicious(params[:username], params[:password])
    end
    flash[:message] = "Importing ..."
    redirect_to :action => "index"
  end

  def update
    bookmark = Bookmark.find(params[:bookmark][:id])
    if bookmark.user == current_user
      new_url = params[:url]["url"]
      if not ((new_url =~ /^http:\/\//) || (new_url =~ /^https:\/\//))
        new_url = "http://" + new_url
      end
      if new_url != bookmark.url
        if bookmark.link.bookmarks.size == 1
          # only one entry, meaning it's gonna be empty
          bookmark.link.destroy
        end
        new_link = Link.find_by_url(new_url)
        if new_link
          bookmark.link = new_link
        else
          bookmark.link = Link.new(:url => new_url)
        end
      end
      bookmark.title = params[:bookmark][:title]
      bookmark.comment = params[:bookmark][:comment]
      bookmark.tag_list = params[:bookmark][:tags]
      bookmark.private = params[:bookmark][:private]
      if bookmark.save
        flash[:message] = "Updated"
      else
      end
      redirect_to :action => "index"
    else
      flash[:message] = "You have no rights here."
      redirect_to :action => "index"
    end
  end

  private
  def check_api
    if current_user && current_user.api_key == params[:api_key]
      return true
    end
    return false
  end

  def get_link_from_short(url)
    link = nil
    link = Link.find_by_short_url(url)
    if link == nil
      # get long url from short (google)
      google_payload = "/urlshortener/v1/url?shortUrl=#{url}&key=#{Settings.goo_gl.api}"
      host = "www.googleapis.com"
      port = "443"
      req = Net::HTTP::Get.new(google_payload)
      req.body = data
      httpd = Net::HTTP.new(host, port)
      httpd.use_ssl = true
      response = httpd.request(req)
      json_res = JSON.parse(response.body)
      long_url = json_res["longUrl"]
      # ok let's find the link from the long_url or create a new Link if not found
      link = Link.find_by_url(long_url) || Link.new(:url => long_url, :short_url => url)
    end
    return link
  end
end
