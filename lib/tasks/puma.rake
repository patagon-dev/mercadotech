namespace :puma do
  desc 'start puma app server'
  task start: :environment do
    system 'puma -C /var/www/puma/puma_config.rb -d'
  end

  desc 'restart puma app server'
  task restart: :environment do
    system 'pumactl -S /var/www/puma/tmp/pids/puma.state restart'
  end

  desc 'stop puma app server'
  task stop: :environment do
    system 'pumactl -S /var/www/puma/tmp/pids/puma.state stop'
  end
end
