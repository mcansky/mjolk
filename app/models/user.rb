require 'net/https'
require 'digest/sha1'

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable
  # tag ownership
  acts_as_tagger
  before_save :set_role, :is_beta
  after_create :send_welcome_email

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :api_key, :name, :remember_me
  has_many :bookmarks, :dependent => :destroy
  has_many :links, :through => :bookmarks
  before_validation :set_initial_name
  
  validates_presence_of :name, :email
  validates_uniqueness_of :name, :case_sensitive => true
  validates_uniqueness_of :email, :case_sensitive => true
  #validates_length_of :password, :minimum => 8
  # check strength of password : again 8 chars min, at least one capitaled letter, at least one normal letter, at least one non alpha characters
  #validates_format_of :password, :with => /^.*(?=.{8,})(?=.*[a-z])(?=.*[A-Z])(?=.*[\d\W]).*$/
  #validates_exclusion_of :name, :in => ['admin', 'login', 'logout'], :message => "name %{value} is reserved."

  def set_role
    if roles == nil
      self.roles = "guest"
    end
  end

  def is_beta
    if Settings.beta && User.all.count >= 42
      self.active = false
    elsif Settings.beta
      self.roles = "beta"
    end
  end

  def send_welcome_email
    if beta?
      General.welcome_beta(id).deliver
    elsif locked?
      General.welcome_too_many(id).deliver
    end
  end

  def self.find_for_twitter_oauth(access_token, signed_in_resource=nil)
    data = access_token['extra']['user_hash']
    if user = User.find_by_name(data["name"])
      user
    else # not found nil (will redirect to sign up form)
      user = nil
    end
    return user
  end
  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.twitter_data"] && session["devise.twitter_data"]["extra"]["user_hash"]
        user.email = data["email"]
      end
    end
  end

  # setting some initial name as devise seems to misunderstand if we put that in the registration form TODO
  def set_initial_name
    self.name = self.email if !self.name
  end

  # import from delicious user username and password pair
  # this pair is not stored locally
  def import_from_delicious(username, password)
    if ((username != nil) && (password != nil))
      # delicious api expected
      http = Net::HTTP.new("api.del.icio.us", 443)
      http.use_ssl = true
      resp = nil
      http.start do |http|
        req = Net::HTTP::Get.new("/v1/posts/all", {"User-Agent" =>
            "altelicious #{Settings.version}"})
        req.basic_auth(username, password)
        response = http.request(req)
        resp = response.body
      end
      import_from_delicious_xml(resp)
    end
  end
  
  def gen_api_key
    self.api_key = Digest::SHA1.hexdigest(Time.now.to_s + self.email + self.name)
  end

  def role_symbols
    e_roles = Array.new
    roles.split.each { |r| e_roles << r.to_sym } unless not roles
    return e_roles
  end

  def roles_to_s
    roles_s = ""
    roles.split.each { |d| roles_s << d + " "}
    roles_s.gsub(/ $/, '')
    return roles_s
  end

  def admin?
    return true if role_symbols.include?(:admin)
    return false
  end

  def beta?
    return true if role_symbols.include?(:beta)
    return false
  end

  def guest?
    return true if role_symbols.include?(:guest)
    return true if role_symbols.count < 1
    return false
  end

  def locked?
    return true if active
    return false
  end

  #private
  # where the work happens
  # use a xml file and extract content
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
          if ((post["href"] =~ /^http:\/\//) || (post["href"] =~ /^https:\/\//))
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
            new_bookmark = Bookmark.new(:title => post['description'], :link_id => link.id, :user_id => self.id, :bookmarked_at => DateTime.parse(post['time']))
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
