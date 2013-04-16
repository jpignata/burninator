require "burninator/broadcaster"
require "burninator/warmer"
require "burninator/connection"
require "burninator/tasks"

class Burninator
  DEFAULT_PERCENTAGE = 5

  EnvironmentError = Class.new(ArgumentError)

  def initialize(redis = nil)
    @redis = redis
  end

  def warm
    trap_signals

    Burninator::Warmer.new(redis, channel, database).run
  end

  def broadcast(options = {})
    percentage = options.fetch(:percentage, DEFAULT_PERCENTAGE)
    ignore = options[:ignore]

    broadcaster = Burninator::Broadcaster.new(redis, channel,
      :ignore => ignore,
      :percentage => percentage
    )

    broadcaster.run
  end

  def channel
    ["burninator", database_id].join(":")
  end

  private

  def trap_signals
    trap(:INT) { abort }
    trap(:TERM) { abort }
  end

  def redis
    @redis ||= Redis.new(:url => redis_url)
  end

  def database
    Connection.new(warm_target_url)
  end

  def database_id
    Digest::SHA1.hexdigest(warm_target_url)
  end

  def warm_target_url
    ENV.fetch("WARM_TARGET_URL")
  rescue KeyError
    raise EnvironmentError,
      "To use burninator, set WARM_TARGET_URL in your environment. See https://github.com/jpignata/burninator for more details."
  end

  def redis_url
    ENV.fetch("REDIS_URL")
  rescue KeyError
    raise EnvironmentError,
      "To use burninator, set REDIS_URL in your environment. See https://github.com/jpignata/burninator for more details."
  end
end
