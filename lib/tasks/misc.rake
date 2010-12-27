# a rake task
namespace :misc do
  desc "Update bookmark privacy"
  task :private_update => :environment do
    Bookmark.all.each do |post|
      if post.private != 1
        post.private = 0
        post.save
      end
    end
  end
end