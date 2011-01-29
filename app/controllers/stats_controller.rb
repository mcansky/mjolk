class StatsController < ApplicationController
  protect_from_forgery
  def index
  end

  def stats
    stats = Stat.all.last(20)
    users = Array.new
    tags = Array.new
    bookmarks = Array.new
    stats.each do |stat|
      users << stat.data[:users]
      tags << stat.data[:tags]
      bookmarks << stat.data[:bookmarks]
    end
    # ordering the points, very important !
    users.sort! { |a,b| a[0] <=> b[0] }
    tags.sort! { |a,b| a[0] <=> b[0] }
    bookmarks.sort! { |a,b| a[0] <=> b[0] }
    if Rails.env == "development"
      i = 0
      2.times do
        i += 1
        date = Time.now + i.day
        number = 300 + rand(2000)
        users << [date.to_i * 1000, number]
        bookmarks << [date.to_i * 1000, number]
        tags << [date.to_i * 1000, number]
      end
    end
    stats = [users, tags, bookmarks]
    respond_to do |format|
      format.json { render :json => stats}
    end
  end
end
