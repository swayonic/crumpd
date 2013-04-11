namespace :cron do
  desc "Updates data from Sitrack's database"
  task :update => :environment do
    now = Time.now
    logger = Rails.logger

    # For each period, if it has been updated:
    #   - 120<t minutes ago: always update
    #   - 60<t<120 minutes ago: sometimes update (1/4 of the time)
    #   - t<60 minutes ago: never update
    for p in Period.updated
      if p.last_updated.nil? or (now - p.last_updated) > 119.minutes
        logger.info 'cron:update --- Needs to update ' + p.name
        Sitrack.update_period p
      elsif (now - p.last_updated) > 59.minutes
        if rand(4) == 0 # 1/4 probability
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
