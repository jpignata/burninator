# burninator

[![Code Climate](https://codeclimate.com/github/jpignata/burninator.png)](https://codeclimate.com/github/jpignata/burninator)
[![Gem Version](https://badge.fury.io/rb/burninator.png)](http://badge.fury.io/rb/burninator)

### Status: Beta (Caveat Utilitor)

## Summary

![burninator](http://25.media.tumblr.com/tumblr_li2bl6oSh01qh5zi3o1_500.jpg)

Warm a standby database with some percentage of real production query traffic.

It's common for Heroku customers to have a standby database follower in the
event of a primary failure, however if you cutover to that follower and its
caches are cold you're likely in for a rough time until its SQL and page
caches warm up.

Burninator uses a Redis pub/sub channel to broadcast some percentage of
query traffic (by default 5%) from Rails application servers to a central
warming process that will run queries against the follower. It uses the
ActiveSupport notifications instrumentation API to listen for queries. These
queries are broadcast through the channel to the warming process which
will run them onto the standby database.

Since you're standby is seeing some percentage of real production query
traffic, its caches should keep warm and ready for failover.

## Installation

Assuming you're using Heroku:

Set your warm target in the environment:

```sh
$ heroku config:add WARM_TARGET_URL="postgres://..."
```

In your Gemfile:

```ruby
gem "burninator"
```

In an initializer:

```ruby
burninator = Burninator.new(redis: $redis, percentage: 25)
burninator.broadcast
```

In your Procfile:

```ruby
burninator: rake burninator:warm
```

Deploy and start burninating:

```sh
$ heroku scale burninator=1
```

## License

Please see LICENSE.
