require 'database_cleaner'
DatabaseCleaner[:mongoid].strategy = :truncation
DatabaseCleaner.strategy = :truncation

RSpec.configure do |config|

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.before(:each) do
    DatabaseCleaner.clean_with(:truncation)
  end

end
