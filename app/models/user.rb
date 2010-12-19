class User < ActiveRecord::Base
  validates_uniqueness_of :email
  validates_length_of :password, :in => 8..20
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  has_many :bookmarks
  has_many :links, :through => :bookmarks
end
