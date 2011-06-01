task :cron => :environment do
  if Stat.last.created_at < (Time.now - 86400)
    Rails.logger.info("Generating stats for #{Time.now.strftime("%d/%m/%Y")}")
    daily_stats = Stat.new
    daily_stats.generate
    daily_stats.save
  else
    Rails.logger.info("Stats for #{Time.now.strftime("%d/%m/%Y")} already exist !")
  end
end