class Burninator
  class Warmer
    def initialize(redis, channel, connection)
      @redis = redis
      @channel = channel
      @connection = connection
    end

    def run
      trap_signals

      begin
        @redis.subscribe(@channel) do |on|
          on.message do |_, serialized|
            event = Marshal.load(serialized)
            process(event)
          end
        end
      rescue Errno::ECONNRESET
        Rails.logger.error("Redis connection reset; resubscribing...")
        retry
      end
    end

    private

    def trap_signals
      trap(:INT) { abort }
      trap(:TERM) { abort }
    end

    def process(event)
      query = event[:sql].squish
      binds = event[:binds]

      @connection.execute(query, binds)
    rescue ActiveRecord::StatementInvalid => e
      Rails.logger.error("#{e.class}: #{e.message}")
    end
  end
end
