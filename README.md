# Priphea

[![Build Status](https://travis-ci.org/stevejackson/priphea.svg?branch=travis-ci)](https://travis-ci.org/stevejackson/priphea)
[![Code Climate](https://codeclimate.com/github/stevejackson/priphea/badges/gpa.svg)](https://codeclimate.com/github/stevejackson/priphea)

Priphea is an offline music library manager and playback app.
It's actually just a Ruby on Rails app running locally that talks to some shell programs behind the scenes.

Priphea is designed specifically for the way I like to organize and listen to music, though feel free to take a look if you're interested!

## Installation

Prerequisites:

* ruby (see .ruby-version)
* exiftool
* mongodb
* taglib
* cmus - `brew install cmus`
* imagemagick - `brew install imagemagick`
* nodejs (for bower)
* phantomjs (for teaspoon tests) - `npm install phantomjs -g`

### Other setup

`./setup.sh`

### Running the tests

There are two test suites: rspec and teaspoon-mocha.

Run them together: `rake test`. Just rspec: `rspec spec`. Just teaspoon: `rake teaspoon`.

## To view database

Could vary, check `config/mongoid.yml`, but probably:

```
mongo 127.0.0.1:27017/priphea-development
```

## To setup database backups

There's a script included which will make a database backup.
The database backup will be saved to the folder defined in the settings,
`database_backup_location`. No prior backups will be overwritten or deleted
automatically.

Set it up in your crontab with something like this line:

```
0 */6 * * * /bin/zsh -l -i -c 'cd /Users/steve/dev/priphea && bin/rails runner -e production '\''BackupDatabase.backup'\'' >> /tmp/priphea_cron.log 2>&1'
```

To restore your backup if necessary, here is an example command:

```
mongorestore --host 127.0.0.1 -d priphea-production --port 27017 /tmp/mongodump1
```

The database is selected automatically (the same database that was used for exporting it.)


## To run the application

### Local dev

```
mongod --dbpath /Users/steve/tmp
rails s thin -p 3000
```

### In production:

I add the following to my `~/.zshrc`:

```
alias priphea='/bin/zsh -l -i -c "/Users/steve/dev/priphea_production/run.sh"'
```

Now I run "priphea" in shell, and it runs the application.

# License

Copyright 2016 Steven Jackson.

