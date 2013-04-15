require "securerandom"
require "active_support/core_ext/string"
require "active_support/notifications"
require "redis"

class Burninator
  class Broadcaster
    KEY = "sql.active_record"

    def initialize(redis, channel, percentage)
      @redis = redis
      @channel = channel
      @percentage = percentage
    end

    def run
      @subscriber ||= ActiveSupport::Notifications.subscribe(KEY) do |*args|
        event = ActiveSupport::Notifications::Event.new(*args)
        sql = event.payload[:sql].squish

        if publish?(sql)
          @redis.publish(@channel, Marshal.dump(event.payload))
        end
      end
    end

    def stop
      ActiveSupport::Notifications.unsubscribe(@subscriber)
    end

    private

    def publish?(sql)
      return false unless sql =~ /\Aselect /i
      return false if sql =~ / for (update|share)\z/i

      SecureRandom.random_number(100 / @percentage) == 0
    end
  end
end
