#!/bin/sh

echo "Starting up Priphea in production mode..."

echo "-----"
echo "Installing bundle..."
cd /Users/steve/dev/priphea_production
bundle install

echo "-----"
echo "Compiling assets..."
RAILS_ENV=production rake assets:precompile

echo "-----"
echo "Attempting to kill existing rails server..."
kill -9 $(cat tmp/pids/server.pid)
kill -9 $(cat tmp/pids/thin.3456.pid)

echo "-----"
echo "Starting up new rails server..."
RAILS_ENV=production rails s thin -p 3456 &> /dev/null &

echo "-----"
echo "Restarting mongodb..."
brew services restart mongodb

echo "-----"
echo "Killing existing cmus..."
kill $(ps aux | grep '[c]mus' | awk '{print $2}')

echo "-----"
echo "Starting up cmus for audio playback..."
cmus
