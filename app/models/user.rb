require 'net/https'

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  # tag ownership
  acts_as_tagger

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  has_many :bookmarks
  has_many :links, :through => :bookmarks
  before_validation :set_initial_name
  
  validates_presence_of :name, :email, :password
  validates_uniqueness_of :name, :case_sensitive => true
  validates_uniqueness_of :email, :case_sensitive => true
  validates_length_of :password, :in => 8..20
  # check strength of password : again 8 chars min, at least one capitaled letter, at least one normal letter, at least one non alpha characters
  validates_format_of :password, :with => /^.*(?=.{8,})(?=.*[a-z])(?=.*[A-Z])(?=.*[\d\W]).*$/
  validates_exclusion_of :name, :in => ['admin', 'login', 'logout'], :message => "name %{value} is reserved."

  # setting some initial name as devise seems to misunderstand if we put that in the registration form TODO
  def set_initial_name
    self.name = self.email
  end

  def import_from_delicious(username, password)
    if ((username != nil) && (password != nil))
      # delicious api expected
      http = Net::HTTP.new("api.del.icio.us", 443)
      http.use_ssl = true
      resp = nil
      http.start do |http|
        req = Net::HTTP::Get.new("/v1/posts/all", {"User-Agent" =>
            "poulpzor v0.1"})
        req.basic_auth(username, password)
        response = http.request(req)
        resp = response.body
      end
      import_from_delicious_xml(resp)
    end
  end

  private
  def import_from_delicious_xml(xml_file)
    # work this out
    xml_stuff = nil
    begin
      xml_stuff = Hpricot(xml_file)
    rescue
      logger.info("Hpricot doesn't like this. this is not xml")
    end
    if xml_stuff
      if (((xml_stuff/"posts") != nil) && ((xml_stuff/"posts").size > 0)) # hooray delicious format ?
        (xml_stuff/"posts"/"post").each do |post|
          
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
            logger.info("link #{url} added")
            link.save
          end

          # now taking care of the bookmark
          if link.users.include?(self)
            # already in
          else
            new_bookmark = Bookmark.new(:title => post['description'], :link_id => link.id, :user_id => self.id)
            new_bookmark.tag_list = post['tag'].gsub(" ",", ")
            if new_bookmark.save
              logger.info("bookmark for #{url} added")
            else
              logger.warn("Error : could not save the new bookmark")
            end
          end 
        end
      end
    end
  end
end
