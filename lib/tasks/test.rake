desc "Run all test suites"
task :test do
  sh 'bundle exec rake teaspoon'
  sh 'bundle exec rspec spec'
end
