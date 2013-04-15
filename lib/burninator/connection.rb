require "active_record"

class Burninator
  class Connection
    def initialize(url, warm_target = nil)
      @warm_target = warm_target
      connect(url)
    end

    def execute(query, binds = [])
      query = "/* BURNINATOR */ " + query
      connection.exec_query(query, nil, binds)
    end

    private

    def warm_target
      @warm_target ||= Class.new(ActiveRecord::Base)
    end

    def connect(url)
      warm_target.establish_connection(url)
    end

    def connection
      @connection ||= warm_target.connection
    end
  end
end
