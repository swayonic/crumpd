namespace :cron do
  desc "Updates data from Sitrack's database"
  task :update => :environment do
    now = Time.now
    logger = Rails.logger

    # If hasn't been update in 30 minutes - do it
    # If has been updated in last 15 minutes - don't do it
    # If in between, do it 1/3 of the time (to get out of sync)
    for p in Period.updated
      if p.last_updated.nil? or (now - p.last_updated) > 29.minutes
        logger.info 'cron:update --- Needs to update ' + p.name
        Sitrack.update_period p
      elsif (now - p.last_updated) > 14.minutes
        if rand(3) == 0 # 1/3 probability
          logger.info 'cron:update --- Chose to update ' + p.name
          Sitrack.update_period p
        else
          logger.info 'cron:update --- Chose not to update ' + p.name
        end
      else
        logger.info "cron:update --- Doesn't need to update " + p.name
      end
    end
  end

end
