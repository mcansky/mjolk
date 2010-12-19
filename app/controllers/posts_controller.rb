require 'xmlsimple'

class PostsController < ApplicationController
  # auth needed !
  before_filter :authenticate_user!

  def index
    @posts = current_user.bookmarks
    xml_posts = Array.new
    @posts.each do |post|
      tags = Array.new
      post.tags.each { |t| tags << t.name }
      xml_posts << {"href" => post.link.url, "description" => post.title, "tag" => tags.join(' ')}
    end
    posts = {:user => current_user.name, :update => current_user.updated_at.utc.strftime("%Y-%m-%dT%H:%M:%SZ"), :tag => "", :total => current_user.bookmarks.size, :post => xml_posts}
    
    respond_to do |format|
      format.html
      format.xml do
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
