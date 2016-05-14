#!/bin/sh

set -e

echo "Starting up Priphea in production mode..."
cd /Users/steve/dev/priphea_production

echo "-----"
echo "Installing bundle..."
bundle install

echo "-----"
echo "Installing bower assets..."
RAILS_ENV=production bundle exec rake bower:install

echo "-----"
echo "Compiling assets..."
RAILS_ENV=production bundle exec rake assets:precompile

echo "-----"
echo "Attempting to kill existing rails server..."
kill -9 $(cat tmp/pids/server.pid)
kill -9 $(cat tmp/pids/thin.3456.pid)

echo "-----"
echo "Starting up new rails server..."
RAILS_ENV=production bundle exec rails s thin -p 3456 &> /dev/null &

echo "-----"
echo "Restarting mongodb..."
brew services restart mongodb

echo "-----"
echo "Killing existing cmus..."
kill $(ps aux | grep '[c]mus' | awk '{print $2}')

echo "-----"
echo "Starting up cmus for audio playback..."
cmus 2> /dev/null
