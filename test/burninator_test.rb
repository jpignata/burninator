require_relative "test_helper"
require "burninator"

class TestBurninator < MiniTest::Unit::TestCase
  def test_channel_generation
    with_env("WARM_TARGET_URL" => "postgres://localhost/burninator") do
      burninator = Burninator.new
      assert_equal "burninator:7649dd6b111e9845eea647853499be62c4aad6d0", burninator.channel
    end
  end

  def test_creates_connection
    redis = stub(:subscribe)

    Burninator::Connection.expects(:new).with("postgres://localhost/burninator")

    with_env("WARM_TARGET_URL" => "postgres://localhost/burninator") do
      burninator = Burninator.new(:redis => redis)
      burninator.warm
    end
  end

  def test_uses_redis_passed_in
    redis = stub(:subscribe)

    Redis.expects(:new).never

    with_env("WARM_TARGET_URL" => "postgres://localhost/burninator") do
      burninator = Burninator.new(:redis => redis)
      burninator.warm
    end
  end

  def test_creates_new_redis_if_not_passed_in
    env = {
      "WARM_TARGET_URL" => "postgres://localhost/burninator",
      "REDIS_URL" => "redis://localhost/0"
    }

    redis = stub(:subscribe)

    Redis.expects(:new).with(:url => "redis://localhost/0").returns(redis)

    with_env(env) do
      Burninator.new.warm
    end
  end

  def test_raises_if_redis_url_missing_and_redis_not_passed
    ENV.delete("REDIS_URL")

    with_env("WARM_TARGET_URL" => "postgres://localhost/burninator") do
      assert_raises(ArgumentError) do
        Burninator.new.warm
      end
    end
  end

  def test_raises_if_warm_target_url_missing
    ENV.delete("WARM_TARGET_URL")

    redis = stub(:subscribe)

    assert_raises(ArgumentError) do
      Burninator.new(:redis => redis).warm
    end
  end
end
