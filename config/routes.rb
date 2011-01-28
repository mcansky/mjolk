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
  match 'posts/import_url', :to => 'posts#import_url'
  match 'posts/import_file', :to => 'posts#import_file'
  resources :bookmarks, :controller => "posts"
  match 'tags/', :to => 'tags#index', :via => :get
  match 'stats/', :to => 'stats#index', :via => :get
  match 'stats/stats.json', :to => 'stats#stats', :via => :get, :format => :json

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products
  resources :posts

  root :to => "application#index"

end
