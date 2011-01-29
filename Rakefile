# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake'

Mjolk::Application.load_tasks

# yard - rdoc
YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb', 'app/**/*.rb']   # optional
  #t.options = ['--any', '--extra', '--opts'] # optional
end