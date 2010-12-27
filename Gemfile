source 'http://rubygems.org'

gem 'rails', '3.0.3'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

# tags
gem 'acts-as-taggable-on'

gem 'sqlite3-ruby', :require => 'sqlite3'

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
end

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
# group :development, :test do
#   gem 'webrat'
# end

# test stuff
group :test do
  gem "shoulda"
  gem 'factory_girl_rails', "1.1.beta1"
  gem "rspec-rails", "2.0.0.beta.12"
end

gem 'rails_admin', :git => 'git://github.com/sferik/rails_admin.git'