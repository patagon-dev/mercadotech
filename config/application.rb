require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Compraagil
  class Application < Rails::Application
    config.to_prepare do
      # Load application's model / class decorators
      Dir.glob(File.join(File.dirname(__FILE__), '../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end

      # Load application's view overrides
      Dir.glob(File.join(File.dirname(__FILE__), '../app/overrides/*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    config.i18n.default_locale = :'es-CL'

    config.active_job.queue_adapter = :sidekiq

    config.exceptions_app = self.routes

    # Application idle session timeout.
    config.session_store :cookie_store, key: '_compraagil_session', expire_after: 6.months

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.hosts = Rails.env.staging? ? ['stage.mercadoempresas.cl', 'stage.mercadodeportivo.cl'] : ['www.mercadogobierno.cl', 'www.mercadopersonas.cl', 'www.mercadotech.cl', 'www.mercadodeportivo.cl', 'www.mercadooficina.cl', 'www.mercadodelvino.cl']
  end
end
