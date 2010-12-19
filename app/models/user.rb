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
end
