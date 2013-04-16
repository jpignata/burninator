require_relative "test_helper"
require "burninator/broadcaster"

class TestBroadcaster < MiniTest::Unit::TestCase
  def setup
    @redis = mock
    channel = "abc123"
    percentage = 100

    @broadcaster = Burninator::Broadcaster.new(@redis, channel,
      :percentage => percentage,
      :ignore => /blogs/
    )
    @broadcaster.run
  end

  def teardown
    @broadcaster.stop
  end

  def test_publishes_selects
    payload = {
      :sql => "SELECT 1"
    }

    @redis.expects(:publish).with("abc123", Marshal.dump(payload))

    ActiveSupport::Notifications.publish("sql.active_record", 0, 0, 1, payload)
  end

  def test_doesnt_publish_inserts
    payload = {
      :sql => "INSERT INTO posts (title) VALUES('title')"
    }

    @redis.expects(:publish).never

    ActiveSupport::Notifications.publish("sql.active_record", 0, 0, 1, payload)
  end

  def test_doesnt_publish_updates
    payload = {
      :sql => "UPDATE posts SET title = 'title'"
    }

    @redis.expects(:publish).never

    ActiveSupport::Notifications.publish("sql.active_record", 0, 0, 1, payload)
  end

  def test_doesnt_publish_for_update_selects
    payload = {
      :sql => "SELECT * FROM posts FOR UPDATE"
    }

    @redis.expects(:publish).never

    ActiveSupport::Notifications.publish("sql.active_record", 0, 0, 1, payload)
  end

  def test_doesnt_publish_for_share_selects
    payload = {
      :sql => "SELECT * FROM posts FOR SHARE"
    }

    @redis.expects(:publish).never

    ActiveSupport::Notifications.publish("sql.active_record", 0, 0, 1, payload)
  end

  def test_doesnt_publish_ignored_strings
    payload = {
      :sql => "SELECT * FROM blogs"
    }

    @redis.expects(:publish).never

    ActiveSupport::Notifications.publish("sql.active_record", 0, 0, 1, payload)
  end
end
