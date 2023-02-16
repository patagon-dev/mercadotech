# Spree Based multivendor application

## Requirements

Make sure you have installed:

* Ruby 2.7.0
* Mysql (5.7)
* Yarn

For Rails version and gems see Gemfile.

## Setup

### Database
This is pretty standard to RoR apps, but always nice to remember: just set up the `config/database.yml` file with your local database credentials. Sample already exists at `config/database.yml.example` for reference

### Environment Variables with Rails 6 Multi Environment credentials

Collect master key from repository owner or project developers and place at `config/credentials/development.key` (on production file will be production.key)

> *With following command edit modify development variables*

> *`EDITOR=nano rails credentials:edit -e development`*

## Installation

So far so good. Now that you are all set up, you can begin to install it.

### Ruby on Rails Application

Run the standard RoR app setup commands: 

1. `bundle install`
2. `rake db:create`
3. `rake db:migrate`
4. `rake db:seed` - if it has seeds

### Sample data

`bundle exec rake spree_sample:load` - This will load sample data check spree documentation for more details

## Running

A simple way you can run the application is by doing: 

1. `puma -C config/puma.rb`.

## Deploy

### Production Server

Login into server

`ssh -p 2222 -tA <your-username>@201.217.242.142 ssh -tA <your-username>@192.168.101.117'`

> it will ask for password, collect your username and password from system admin

1. `cd cd /var/www/compraagil/`
2. `git pull origin master`
3. `systemctl restart puma`

Additional commands to control app server

1. `systemctl start puma`
2. `systemctl stop puma`

Commands to control sidekiq

1. `systemctl start sidekiq`
2. `systemctl restart sidekiq`
3. `systemctl stop sidekiq`

# Note

If you think something is wrong, missing or could be improved on this README, please feel free to update it.
