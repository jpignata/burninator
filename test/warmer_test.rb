require_relative "test_helper"
require "burninator/warmer"
require "ostruct"

class MockRedis
  def subscribe(channel)
    @channel = channel
    yield self
  end

  def message(&block)
    @subscriber = block
  end

  def publish(data)
    @subscriber.call(@channel, data)
  end
end

class TestWarmer < MiniTest::Unit::TestCase
  def setup
    @channel = "abc123"
    @redis = MockRedis.new
    @connection = mock
  end

  def test_executes_received_query
    query = "SELECT * FROM posts WHERE id = $1"
    column = OpenStruct.new(name: "id")
    binds = [column, 1]

    warmer = Burninator::Warmer.new(@redis, @channel, @connection)
    warmer.run

    payload = {
      sql: query,
      binds: binds
    }

    @connection.expects(:execute).with(query, binds)

    @redis.publish(Marshal.dump(payload))
  end

  def test_reconnects_on_econnreset
    @redis.expects(:subscribe).twice.raises(Errno::ECONNRESET).then.returns(true)

    warmer = Burninator::Warmer.new(@redis, @channel, @connection)
    warmer.run
  end

  def test_logs_reconnect
    @redis.stubs(:subscribe).raises(Errno::ECONNRESET).then.returns(true)

    warmer = Burninator::Warmer.new(@redis, @channel, @connection)
    warmer.run

    assert_equal "Redis connection reset; resubscribing...", Rails.log.last
  end
end
