class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  has_many :bookmarks
  has_many :links, :through => :bookmarks
  
  validates_presence_of :name, :email
  validates_uniqueness_of :name, :case_sensitive => true
  validates_uniqueness_of :email, :case_sensitive => true
  validates_length_of :password, :in => 8..20
  validates_exclusion_of :name, :in => ['admin', 'login', 'logout'], :message => "name %{value} is reserved."
end
