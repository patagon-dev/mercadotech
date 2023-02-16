source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.1.3'
# Use mysql2 as the database for Active Record
gem 'mysql2'
# Use Puma as the app server
gem 'puma', '~> 4.1'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 4.0'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
gem 'redis'
gem 'hiredis'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
gem 'image_processing', '~> 1.2'

gem 'spree', '~> 4.2'
gem 'spree_auth_devise', '~> 4.3'
gem 'spree_gateway', '~> 3.9'
gem 'deface'

gem 'spree_multi_vendor', github: 'spree-contrib/spree_multi_vendor'
gem 'spree_multi_vende', git: 'git@github.com:marketshop-io/multivende.git', branch: 'main'
gem 'spree_reviews', github: 'spree-contrib/spree_reviews'

gem 'omniauth_openid_connect'
gem 'sidekiq'
gem 'spree_i18n', github: 'spree-contrib/spree_i18n'
gem 'spree_related_products', github: 'spree-contrib/spree_related_products' # for related products
gem 'spree_social', github: 'spree-contrib/spree_social'
gem 'spree_slider', github: 'spree-contrib/spree_slider'

gem 'coffee-rails'

gem 'spree_multi_domain', github: 'nmella/spree-multi-domain', branch: 'master'

gem 'spree_analytics_trackers'
gem 'spree_static_content', github: 'spree-contrib/spree_static_content'
gem 'rollbar'
gem 'scout_apm'
gem 'savon', '~> 2.12.0'
gem 'signer'

gem 'searchkick'
gem 'spree_searchkick', github: 'marketshop-io/spree_searchkick'
gem 'spree_counties', github: 'nmella/spree_counties'

gem 'spree_sitemap', github: 'spree-contrib/spree_sitemap'
gem 'spree_volume_pricing', github: 'spree-contrib/spree_volume_pricing'

gem 'aws-sdk-s3', '~> 1'
gem 'combine_pdf'
gem 'whenever', require: false
gem 'wicked_pdf'
gem 'wkhtmltopdf-binary'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '1.7.2', require: false
gem 'devise_saml_authenticatable', github: 'apokalipto/devise_saml_authenticatable'
gem 'rubocop', require: false
gem 'spreadsheet', '~> 1.2', '>= 1.2.6'

gem 'spree_mail_settings', github: 'nmella/spree_mail_settings'
gem "sidekiq-cron", "~> 1.1"
gem 'rack-mini-profiler'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'shoulda-matchers', '~> 4.0'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'listen'
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'letter_opener'
  gem 'spring'
  gem 'spring-watcher-listen'
end

group :development, :staging do
  gem 'bullet' # for n+1 query
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'database_cleaner'
  gem 'factory_bot_rails', '~> 4.10.0'
  gem 'ffaker'
  gem 'rspec-rails'
  gem 'webdrivers'
  gem 'rspec-sidekiq'
  gem 'rails-controller-testing'
  gem 'rspec-activemodel-mocks'
  gem 'rspec_junit_formatter'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
