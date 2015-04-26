## Installation

Prerequisites:

* Ruby (see .ruby-version)
* exiftool
* mongodb

```
bundle install
rails s thin -p 3000
```

## To view database

Could vary, check `config/mongoid.yml`, but probably:

```
mongo 127.0.0.1:27017/priphea-development
```
