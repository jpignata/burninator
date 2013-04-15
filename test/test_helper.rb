$: << "./lib"

require "minitest/autorun"
require "mocha/setup"

module Rails
  class Railtie
    def self.rake_tasks
      yield
    end
  end
end

def with_env(variables)
  original = {}

  variables.each do |key, value|
    original[key], ENV[key] = ENV[key], value
  end

  yield
ensure
  original.each { |key, value| ENV[key] = value }
end
