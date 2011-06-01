task :cron => :environment do
  if Stat.last.created_at < (Time.now - 86400)
    daily_stats = Stat.new
    daily_stats.generate
    daily_stats.save
  end
end