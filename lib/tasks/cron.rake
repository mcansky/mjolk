task :cron => :environment do
  if Stat.last.created_at.day < Time.now.day
    daily_stats = Stat.new
    daily_stats.generate
    daily_stats.save
  end
end