module BackupDatabase
  def self.backup
    cron_log = Logger.new("#{Rails.root}/log/cron_#{Rails.env}.log")

    datetime = DateTime.now.to_s
    filename = "backup_#{datetime}"
    file = File.join(Settings.database_backups_location, filename)

    cron_log.info("Attempting to run database backup to file: #{file}")

    if Rails.env.development?
      output = system %Q{ mongodump --host 127.0.0.1 --port 27017 --db priphea-development --out #{file} }
    elsif Rails.env.production?
      output = system %Q{ mongodump --host 127.0.0.1 --port 27017 --db priphea-production --out #{file} }
    end
    
    cron_log.info "mongodumb output: #{output}"

    cron_log.info("Ran mongodump.")
  end
end
