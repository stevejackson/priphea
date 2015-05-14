## Installation

Prerequisites:

* Ruby (see .ruby-version)
* exiftool
* mongodb

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
* * * * * /bin/zsh -l -i -c 'cd /Users/steve/dev/priphea && bin/rails runner -e development '\''BackupDatabase.backup'\'' >> /tmp/priphea_cron.log 2>&1'
```

To restore your backup if necessary, here is an example command:

```
mongorestore --host 127.0.0.1 --port 27017 /tmp/mongodump1
```

The database is selected automatically (the same database that was used for exporting it.)


## To run the application

I add the following to my `~/.zshrc`:

```
alias priphea='/bin/zsh -l -i -c "/Users/steve/dev/priphea_production/run.sh"'
```

Now I run "priphea" in shell, and it runs the application.

You must add the following to your crontab to handle file change notifications:

```
* * * * * /bin/zsh -l -i -c 'cd /Users/steve/dev/priphea_production && bin/rails runner -e production '\''FileNotificationProcessor.process!'\'' >> /tmp/priphea_cron.log 2>&1'
```

*You must also change the music lib AND database hardcoded within `Guardfile`.*
