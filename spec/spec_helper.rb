require 'database_cleaner'
DatabaseCleaner[:mongoid].strategy = :truncation
DatabaseCleaner.strategy = :truncation

require 'factory_girl_rails'

def prepare_test_songs
  # remove any existing test_songs
  copied_data_files = File.join(Rails.root, "spec", "data", "test_songs")
  FileUtils.rm_rf(Dir.glob("#{copied_data_files}/*"))

  # copy all files from original_songs to test_songs.
  original_data_files = File.join(Rails.root, "spec", "data", "original_songs")
  copied_data_files = File.join(Rails.root, "spec", "data", "test_songs")
  FileUtils.cp_r(Dir.glob(original_data_files + "/*"), copied_data_files)
end

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.before :suite do
    prepare_test_songs
  end

  config.before(:each) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:example, :file_cleaning => :full) do
    prepare_test_songs
  end

  config.after(:each) do
  end

end
