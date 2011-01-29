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
    stats = [users, tags, bookmarks]
    respond_to do |format|
      format.json { render :json => stats}
    end
  end
end
