require 'xmlsimple'

class V1::PostsController < ApplicationController  
  # auth needed !x
  before_filter :authenticate_user!
  authorize_resource :class => "Bookmark"
  cache_sweeper :bookmark_sweeper

  ##
  # return updated time *TODO*
  #
  def update
  end

  ##
  # add a new bookmark
  #
  # http://www.mjolk.net/v1/posts/add _or_ http://yourhost/v1/posts/add
  #
  # args :
  # * url (req)
  # * description (req)
  # * tags
  # * dt
  # * shared
  # * not implemented : replace, extended
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
      link = Link.find_by_url(url) || Link.new(:url => url)
      link.save
      if link.users.include?(current_user)
        flash[:message] = "Already in"
      else
        datetime = nil
        datetime = params[:dt] if params[:dt]
        description = params['description'] || params[:bookmark]['title']

        new_bookmark = Bookmark.new(:title => description, :link_id => link.id, :user_id => current_user.id, :bookmarked_at => (datetime || Time.now))
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
    end
    respond_to do |format|
      format.xml do
        if incomplete || error
          render :xml => "<?xml version='1.0' standalone='yes'?>\n<result code=\"something went wrong\" />"
        else
          render :xml => "<?xml version='1.0' standalone='yes'?>\n<result code=\"done\" />"
        end
      end
    end
  end

  ##
  # delete a post using url as key
  #
  # http://www.mjolk.net/v1/posts/delete _or_ http://yourhost/v1/posts/delete
  #
  # params
  # * url
  def delete
    error = true
    if params[:url]
      link = Bookmark.find_by_url(params[:url]) || nil
      if (link && link.users.include(current_user))
        bookmark = current_user.bookmarks.find(:all, :conditions => ["link_id = ?", link.id])
        bookmark.destroy
        link.destroy if link.bookmarks.size == 0 # destroy the link if no bookmarks are left
        error = false
      end
    end

    respond_to do |format|
      format.xml do
        if error
          render :xml => "<?xml version='1.0' standalone='yes'?>\n<result code=\"something went wrong\" />"
        else
          render :xml => "<?xml version='1.0' standalone='yes'?>\n<result code=\"done\" />"
        end
      end
    end
  end

  ##
  # return one or more post for a single day. if no date is passed the last day is returned
  #
  # http://www.mjolk.net/v1/posts/get _or_ http://yourhost/v1/posts/get
  #
  # params :
  # * tag : {TAG} + {TAG} + {TAG} ...     _optionnal_
  # * dt (date) : {CCYY-MM-DDThh:mm:ssZ}  _optionnal_
  # * url : fetch bookmark with that url  _optionnal_
  # * hashes: fetch bookmarks using their url hashes as key (md5) _optionnal_ *TODO*
  # * meta (boolean): include change detection meta for each item _optionnal_
  def get
    error = true
    posts = Array.new
    unless (params[:tag] && params[:dt] && params[:url] && params[:hashes] && params[:meta])
      last_post = current_user.bookmarks.last
      posts = current_user.bookmarks.find(:all, :conditions => ["bookmarked_at = ?", last_post.bookmarked_at])
      error = false
    else
      # building conditions
      conditions = Array.new
      conditions[0] = ""
      tags = Array.new
      if params[:dt]
        conditions[0] = "bookmarked_at = ?"
        conditions << DateTime.parse(params[:dt])
      end
      if params[:url]
        url = Link.find_by_url(params[:url])
        conditions[0] += " AND " if (params[:dt])
        conditions[0] += "link_id = ?"
        conditions << url.id
      end
      # TODO
      if params[:hashes]
      end
      if params[:tag]
        tags = params[:tag].split(/[ +]/)
        posts = current_user.bookmarks.find(:all, :conditions => conditions).tagged_with(tags, :match_all => true)
        error = false
      else
        posts = current_user.bookmarks.find(:all, :conditions => conditions)
        error = false
      end
    end
    
    # return results
    respond_to do |format|
      format.xml do
        if current_user
          xml_posts = Array.new
          posts.each do |post|
            tags = Array.new
            post.tags.each { |t| tags << t.name } if post.tags.count > 0
            if params[:meta]
              xml_posts << {"href" => post.link.url, "description" => post.title, "tag" => tags.join(' '), "meta" => post.meta}
            else
              xml_posts << {"href" => post.link.url, "description" => post.title, "tag" => tags.join(' ')}
            end
          end
          meta = Digest::MD5.hexdigest(current_user.name + current_user.updated_at.utc.strftime("%Y-%m-%dT%H:%M:%SZ"))
          posts = {:user => current_user.name, :update => current_user.updated_at.utc.strftime("%Y-%m-%dT%H:%M:%SZ"), :hash => meta, :tag => "", :total => current_user.bookmarks.size, :post => xml_posts}
          xml_output = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" + XmlSimple.xml_out(posts).gsub("opt","posts")
          render :xml => xml_output
        else
          render :xml => "<?xml version='1.0' standalone='yes'?>\n<result code=\"something went wrong\" />"
        end
      end
    end
  end

  ## 
  # return a list of recent posts
  #
  # http://www.mjolk.net/v1/posts/recent _or_ http://yourhost/v1/posts/recent
  #
  # args :
  # * tag = {TAG} tag to filter _optionnal_
  # * count = 1..100 number of posts to return (default 15, max 100)
  def recent
    error = true
    posts = Array.new
    # limit
    limit = params[:count] || 15
    limit = 100 if limit > 100
    # getting the posts
    if params[:tag]
      tags = params[:tag].split(/[ +]/)
      posts = current_user.bookmarks.last(limit).tagged_with(tags, :match_all => true)
    else
      posts = current_user.bookmarks.last(limit)
    end
    # return results
    respond_to do |format|
      format.xml do
        if current_user
          xml_posts = Array.new
          posts.each do |post|
            tags = Array.new
            post.tags.each { |t| tags << t.name } if post.tags.count > 0
            if params[:meta]
              xml_posts << {"href" => post.link.url, "description" => post.title, "tag" => tags.join(' '), "meta" => post.meta}
            else
              xml_posts << {"href" => post.link.url, "description" => post.title, "tag" => tags.join(' ')}
            end
          end
          meta = Digest::MD5.hexdigest(current_user.name + current_user.updated_at.utc.strftime("%Y-%m-%dT%H:%M:%SZ"))
          posts = {:user => current_user.name, :update => current_user.updated_at.utc.strftime("%Y-%m-%dT%H:%M:%SZ"), :hash => meta, :tag => "", :total => current_user.bookmarks.size, :post => xml_posts}
          xml_output = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" + XmlSimple.xml_out(posts).gsub("opt","posts")
          render :xml => xml_output
        else
          render :xml => "<?xml version='1.0' standalone='yes'?>\n<result code=\"something went wrong\" />"
        end
      end
    end
  end

  ##
  # return a list of dates with a count of posts for each *TODO*
  #
  # http://www.mjolk.net/v1/posts/dates _or_ http://yourhost/v1/posts/dates
  #
  def dates
  end

  ##
  # return all posts
  #
  # http://www.mjolk.net/v1/posts/all _or_ http://yourhost/v1/posts/all
  #
  # params :
  # * tag : filter by tag (list ok) _optionnal_
  # * start : number from where to start in the results _optionnal_
  # * results : number limit for results _optionnal_
  # * fromdt : date from which posts should be taken _optionnal_
  # * todt : date to which posts should be taken _optionnal_
  # * meta : include meta for posts _optionnal_
  def index
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
    if params[:fromdt]
      conditions[0] = "bookmarked_at >= ?"
      conditions << DateTime.parse(params[:fromdt])
    end
    if params[:todt]
      conditions[0] += " AND " if params[:fromdt]
      conditions[0] += "bookmarked_at <= ?"
      conditions << DateTime.parse(params[:todt])
    end
    if params[:username]
      # filter private ones
      conditions[0] += " AND " if (params[:fromdt] || params[:todt])
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
      tags = params[:tag].split(/[ +]/)
      if user
        posts = user.bookmarks.tagged_with(params[:tag], :match_all => true).find(:all, :offset => (params[:start] || 0), :limit => (params[:results] || limit), :conditions => conditions, :order => "bookmarked_at DESC")
      else
        posts = Bookmark.tagged_with(params[:tag], :match_all => true).find(:all, :offset => (params[:start] || 0), :limit => (params[:results] || limit), :conditions => conditions, :order => "bookmarked_at DESC")
      end
    else
      if user
        posts = user.bookmarks.find(:all, :offset => (params[:start] || 0), :limit => (params[:results] || limit), :conditions => conditions, :order => "bookmarked_at DESC")
      else
        posts = Bookmark.find(:all, :offset => (params[:start] || 0), :limit => (params[:results] || limit), :conditions => conditions, :order => "bookmarked_at DESC")
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
    respond_to do |format|
      format.xml do
        if current_user
          xml_posts = Array.new
          the_posts.each do |post|
            tags = Array.new
            post.tags.each { |t| tags << t.name } if post.tags.count > 0
            xml_posts << {"href" => post.link.url, "description" => post.title, "tag" => tags.join(' ')}
          end
          meta = Digest::MD5.hexdigest(current_user.name + current_user.updated_at.utc.strftime("%Y-%m-%dT%H:%M:%SZ"))
          posts = {:user => current_user.name, :update => current_user.updated_at.utc.strftime("%Y-%m-%dT%H:%M:%SZ"), :hash => meta, :tag => "", :total => current_user.bookmarks.size, :post => xml_posts}
          xml_output = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" + XmlSimple.xml_out(posts).gsub("opt","posts")
          render :xml => xml_output
        else
          render :xml => "<?xml version='1.0' standalone='yes'?>\n<result code=\"something went wrong\" />"
        end
      end
    end
  end

  ## 
  # return a list of tags already used for the url given *TODO*
  #
  # http://www.mjolk.net/v1/posts/suggest _or_ http://yourhost/v1/posts/suggest
  #
  # params: 
  # * url
  #
  def suggest
  end

  private
  def check_api
    if current_user && current_user.api_key == params[:api_key]
      return true
    end
    return false
  end
end