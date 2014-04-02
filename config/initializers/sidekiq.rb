sidekiq_redis = { url: $redis.url, namespace: 'sidekiq' }

Sidetiq.configure do |config|
  # we only check for new jobs once every 5 seconds
  # to cut down on cpu cost
  config.resolution = 5
end

Sidekiq.logger.level = Logger::INFO

if Rails.env.production?
  require 'autoscaler/sidekiq'
  require 'autoscaler/heroku_scaler'

  Sidekiq.configure_server do |config|
    config.redis = sidekiq_redis
    config.server_middleware do |chain|
      chain.add(Autoscaler::Sidekiq::Server, Autoscaler::HerokuScaler.new('worker'), 60)
    end
  end

  Sidekiq.configure_client do |config|
    config.redis = sidekiq_redis
    config.client_middleware do |chain|
      chain.add Autoscaler::Sidekiq::Client, 'default' => Autoscaler::HerokuScaler.new('worker')
    end
  end
else
  Sidekiq.configure_server { |config| config.redis = sidekiq_redis }
  Sidekiq.configure_client { |config| config.redis = sidekiq_redis }
end
