Mjolk::Application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action
  match 'posts/all' => 'posts#index'
  match 'posts/add' => 'posts#create', :via => :post
  match 'posts/delete' => 'posts#destroy', :via => :post
  match 'posts/edit' => 'posts#edit'
  match 'posts/update' => 'posts#update'
  match 'posts/import' => 'posts#import'
  match 'posts/import_url' => 'posts#import_url'
  match 'posts/import_file' => 'posts#import_file'
  resources :bookmarks, :controller => "posts"
  match 'tags/' => 'tags#index', :via => :get
  match 'stats/' => 'stats#index', :via => :get
  match 'stats/stats.json' => 'stats#stats', :via => :get, :format => :json

  scope 'admin', :name_prefix => "admin" do
    resources :users, :controller => "admin/users"
  end

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products
  resources :posts

  root :to => "application#index"

end
