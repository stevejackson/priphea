source 'https://rubygems.org'

gem 'rails', '~> 4.2'
gem 'rake', '~> 11'
gem 'mongoid', '~> 4.0'

gem 'rails_config', '~> 0.3'

gem 'therubyracer', platforms: :ruby

gem 'ransack', '~> 1.6'

gem 'taglib-ruby', '~> 0.7'
gem 'mini_exiftool', '~> 2.7'

# assets
gem 'bower-rails'
gem 'sprockets-es6' # Babel JS
gem 'angular-rails-templates'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'

group :development do
  gem 'thin', '~> 1.6'
  gem 'meta_request', '~> 0.3'

  gem 'better_errors', '~> 1.1'
  gem 'binding_of_caller', '~> 0.7'

  gem 'ruby-prof'
end

group :development, :test do
  gem 'pry-rails', '~> 0.3'
  gem 'pry-byebug', '~> 1'

  gem 'rspec-rails', '~> 3.0'
  gem 'database_cleaner', '~> 1.2'

  gem 'teaspoon-mocha'
  gem 'coffee-rails' # required for teaspoon to work due to a bug
end

group :test do
  gem 'shoulda-matchers', '~> 3.0'
  gem 'factory_girl_rails'
end
