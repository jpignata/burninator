require_relative "test_helper"
require "burninator/connection"

class TestConnection < MiniTest::Unit::TestCase
  def test_connects
    warm_target = mock
    warm_target.expects(:establish_connection).with("sqlite3://burninator")

    Burninator::Connection.new("sqlite3://burninator", warm_target)
  end

  def test_execute
    expected_query = "/* BURNINATOR */ SELECT 1"

    db_conn = mock
    db_conn.expects(:exec_query).with(expected_query, nil, [])

    connection = Burninator::Connection.new("sqlite3://burninator")
    connection.stubs(:connection).returns(db_conn)
    connection.execute("SELECT 1")
  end
end
