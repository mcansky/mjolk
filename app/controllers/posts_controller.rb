require 'xmlsimple'

class PostsController < ApplicationController
  # auth needed !
  before_filter :authenticate_user!

  # params :
  # &tag={TAG}
  # (optional) Filter by this tag.
  # &start={#}
  # (optional) Start returning posts this many results into the set.
  # &results={#}
  # (optional) Return this many results.
  # &fromdt={CCYY-MM-DDThh:mm:ssZ}
  # (optional) Filter for posts on this date or later
  # &todt={CCYY-MM-DDThh:mm:ssZ}
  # (optional) Filter for posts on this date or earlier
  # &meta=yes
  # (optional) Include change detection signatures on each item in a 'meta' attribute. Clients wishing to maintain a synchronized local store of bookmarks should retain the value of this attribute - its value will change when any significant field of the bookmark changes.
  def index
    # building conditions
    conditions = Array.new
    if params[:fromdt]
      conditions[0] = "bookmarked_at >= ?"
      conditions << DateTime.parse(params[:fromdt])
    end
    if params[:todt]
      conditions[0] += " AND " if params[:fromdt]
      conditions[0] += "bookmarked_at <= ?"
      conditions << DateTime.parse(params[:todt])
    end
    if params[:tag]
      @posts = current_user.bookmarks.tagged_with(params[:tag]).find(:all, :offset => (params[:start] || 0), :limit => (params[:results] || -1), :conditions => conditions, :order => "bookmarked_at DESC")
    else  
      @posts = current_user.bookmarks.find(:all, :offset => (params[:start] || 0), :limit => (params[:results] || -1), :conditions => conditions, :order => "bookmarked_at DESC")
    end
    respond_to do |format|
      format.html
      format.xml do
        xml_posts = Array.new
        @posts.each do |post|
          tags = Array.new
          post.tags.each { |t| tags << t.name }
          xml_posts << {"href" => post.link.url, "description" => post.title, "tag" => tags.join(' ')}
        end
        posts = {:user => current_user.name, :update => current_user.updated_at.utc.strftime("%Y-%m-%dT%H:%M:%SZ"), :hash => post.meta, :tag => "", :total => current_user.bookmarks.size, :post => xml_posts}
        xml_output = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" + XmlSimple.xml_out(posts).gsub("opt","posts")
        render :xml => xml_output
      end
    end
  end

  def import
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
            if post["href"] =~ /^http:\/\//
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
      redirect_to login_path
    end
  end
end
