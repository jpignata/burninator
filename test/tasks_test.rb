require_relative "test_helper"
require "burninator/tasks"

class TestBroadcaster < MiniTest::Unit::TestCase
  def test_warm_task
    Burninator.any_instance.expects(:warm)
    Rake::Task["burninator:warm"].invoke
  end
end
