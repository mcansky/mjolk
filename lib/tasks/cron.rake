task :cron => :environment do
  if Time.now.hour == 1
    daily_stats = Stat.new
    daily_stats.generate
    daily_stats.save
  end
end