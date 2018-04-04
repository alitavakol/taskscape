source 'https://rubygems.org'
git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end
ruby '2.4.1'
gem 'rails', '~> 5.1.5'
gem 'puma', '~> 3.7'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
# gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'
group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'capybara', '~> 2.13'
  gem 'selenium-webdriver'
end
group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'binding_of_caller'
end
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem 'rails_admin'
gem 'bootstrap', '~> 4.0.0'
gem 'bourbon'
gem 'devise'
gem 'devise_invitable'
gem 'haml-rails'
gem 'high_voltage'
gem 'jquery-rails'
gem 'mysql2', '~> 0.4'
gem 'pundit'
group :development do
  gem 'better_errors'
  gem 'guard-bundler'
  gem 'guard-rails'
  gem 'guard-rspec'
  gem 'html2haml'
  gem 'rails_layout'
  gem 'rb-fchange', :require=>false
  gem 'rb-fsevent', :require=>false
  gem 'rb-inotify', :require=>false
  gem 'spring-commands-rspec'
  gem 'annotate'
  gem "letter_opener" # opens email body in a new browser tab instead of actually sending it
end
group :development, :test do
  gem 'factory_bot_rails'
  gem 'rspec-rails'
end
group :test do
  gem 'database_cleaner'
  gem 'launchy'
end

gem 'faker'

# javascript MVC library for the client side
# I customized backbone.js, so comment the gem and add it manually into vendor/assets
# gem 'rails-backbone', github: 'codebrew/backbone-rails', branch: 'master'

# use haml code in assets
gem 'haml_coffee_assets'

gem 'font-awesome-rails'

# file and avatar attachments
gem "paperclip", "~> 5.2.1"

# toast notifications
# https://github.com/CodeSeven/toastr
gem 'toastr-rails'

# progress bar for client-side ajax
gem 'nprogress-rails'

gem 'simple_form'

gem 'pg', group: :production
gem 'rails_12factor'