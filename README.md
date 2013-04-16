# burninator

[![Code Climate](https://codeclimate.com/github/jpignata/burninator.png)](https://codeclimate.com/github/jpignata/burninator)
[![Build Status](https://travis-ci.org/jpignata/burninator.png)](https://travis-ci.org/jpignata/burninator)
[![Gem Version](https://badge.fury.io/rb/burninator.png)](http://badge.fury.io/rb/burninator)

### Status: Beta (Caveat Utilitor)

## Summary

![burninator](http://25.media.tumblr.com/tumblr_li2bl6oSh01qh5zi3o1_500.jpg)

Warm a standby database with some percentage of real production query traffic.

It's common for Heroku customers to have a standby database follower in the
event of a primary failure, however if you cutover to that follower and it hasn't
yet served any queries you're likely in for a rough time until its SQL and page
caches warm up.

Burninator uses a Redis pub/sub channel to broadcast some percentage of
query traffic from Rails application servers to a central
warming process that will run queries against the follower. It uses the
ActiveSupport notifications instrumentation API to listen for queries.

Since your standby is seeing some percentage of real production query
traffic, its caches should keep warm and ready for failover.

## Requirements

* Rails application (only tested against 3.2.12)
* Ruby 1.9+
* Redis

## Installation

### Heroku

#### Set your warm target in the environment

```sh
$ heroku config:add WARM_TARGET_URL="postgres://..."
```

#### Add the gem in your Gemfile

```ruby
gem "burninator"
```

#### Add  `config/initializers/burninator.rb`

```ruby
burninator = Burninator.new($redis)
burninator.broadcast(percentage: 25)
```

If you leave off the `redis` parameter, it will create a new connection
using what's configured in the environment as `REDIS_URL`.

`percentage` will default to 5%.

If either `WARM_TARGET_URL` is missing or `REDIS_URL` is missing and a `redis`
parameter is not provided, a `Burninator::EnvironmentError` will be raised.

#### Add the process in your Procfile:

```ruby
burninator: rake burninator:warm
```

#### Deploy and start burninating

```sh
$ heroku scale burninator=1
```

## License

Please see LICENSE.
