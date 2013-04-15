class Burninator
  class Warmer
    def initialize(redis, channel, connection)
      @redis = redis
      @channel = channel
      @connection = connection
    end

    def run
      @redis.subscribe(@channel) do |on|
        on.message do |_, serialized|
          event = Marshal.load(serialized)
          process(event)
        end
      end
    end

    private

    def process(event)
      query = event[:sql]
      binds = event[:binds]

      @connection.execute(query, binds)
    rescue ActiveRecord::StatementInvalid => e
      Rails.logger.error("Error running #{query}")
      Rails.logger.error("#{e.class}: #{e.message}")
    end
  end
end
