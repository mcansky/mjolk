Mjolk::Application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action
  match 'posts/all', :to => 'posts#index'
  match 'posts/add', :to => 'posts#create', :via => :post
  match 'posts/delete', :to => 'posts#destroy', :via => :post
  match 'posts/edit', :to => 'posts#edit'
  match 'posts/update', :to => 'posts#update'
  match 'posts/import', :to => 'posts#import'
  match 'posts/import_url', :to => 'posts#import_url', :via => :post
  match 'posts/import_file', :to => 'posts#import_file'
  resources :bookmarks, :controller => "posts"

  # tags
  match 'tags/', :to => 'tags#index', :via => :get

  # groups
  resources :groups
  match 'groups/join', :to => 'groups#join', :via => [:delete, :post]

  # stats
  match 'stats/', :to => 'stats#index', :via => :get
  match 'stats/stats.json', :to => 'stats#stats', :via => :get, :format => :json

  # follow
  #match 'users/follow/:id', :to => 'users#follow', :via => [:delete, :post]
  match "users/follow/:id" => 'users#follow', :via => [:get, :post]

  # api
  match 'v1/posts/all', :to => 'v1/posts#index'
  match 'v1/posts/get', :to => 'v1/posts#get'
  match 'v1/posts/add', :to => 'v1/posts#create', :via => :post
  match 'v1/posts/delete', :to => 'v1/posts#destroy', :via => :post
  match 'v1/posts/update', :to => 'v1/posts#update'

  # admin
  match 'admin/users/mass_mail', :to => 'admin/users#mass_mail', :via => :get
  match 'admin/users/mass_email_send', :to => 'admin/users#mass_email_send', :via => :post
  scope 'admin', :as => "admin" do
    resources :users, :controller => "admin/users"
  end

  # 
  resources :posts

  root :to => "application#index"

end
