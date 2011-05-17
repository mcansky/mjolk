source 'http://rubygems.org'

gem 'rails', '3.0.5'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

# tags
gem 'acts-as-taggable-on'

gem 'sqlite3-ruby', :require => 'sqlite3'

# some good jquery
gem "jquery-rails"

# authorizations
gem "declarative_authorization"

# pagination
gem "will_paginate", "~> 3.0.pre2"

# Use unicorn as the web server
# gem 'unicorn'
gem "thin"
gem "xml-simple"

# initial basic styling
gem "flutie"

# Deploy with Capistrano
# gem 'capistrano'

# auth stuff
gem "devise", :git => "git://github.com/plataformatec/devise.git", :tag => "v1.2.rc"
gem "oa-oauth", :require => "omniauth/oauth"
gem "cancan"

# config stuff
gem "rails_config"

# To use debugger (ruby-debug for Ruby 1.8.7+, ruby-debug19 for Ruby 1.9.2+)
# gem 'ruby-debug'
# gem 'ruby-debug19'

# Bundle the extra gems:
# gem 'bj'
# gem 'nokogiri'
# gem 'sqlite3-ruby', :require => 'sqlite3'
# gem 'aws-s3', :require => 'aws/s3'
gem 'haml'
gem 'hpricot'

group :production do
	gem "pg"
	gem "dalli"
end

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
# group :development, :test do
#   gem 'webrat'
# end

gem 'hoptoad_notifier'

# test stuff
group :test do
  gem "shoulda"
  gem 'factory_girl_rails'
end