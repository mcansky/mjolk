class ApplicationController < ActionController::Base
  #protect_from_forgery

  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = exception.message
    redirect_to root_url
  end

  def index
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
    # filter private ones
    conditions[0] += " AND " if (params[:fromdt] || params[:todt])
    conditions[0] += "private = ?"
    conditions << 0
    size = Bookmark.all.count
    @posts = Bookmark.find(:all, :limit => 20, :conditions => conditions, :order => "bookmarked_at DESC")
    @tags = Bookmark.tag_counts_on(:tags)
    respond_to do |format|
      format.html
      format.xml do
        xml_posts = Array.new
        @posts[0..19].each do |post|
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
end
