authorization do
  role :admin do
    has_permission_on :rails_admin_history, :to => :list
    has_permission_on :rails_admin_main, :to => [:index, :show, :new, :edit, :create, :update, :destroy, :list, :delete, :get_pages, :show_history]
  end
end