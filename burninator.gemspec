Gem::Specification.new do |s|
  s.name        = "burninator"
  s.version     = "0.0.1"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["John Pignata"]
  s.email       = ["john@pignata.com"]
  s.homepage    = "http://github.com/jpignata/burninator"
  s.summary     = "Run queries to a Rails application on your standby databases"
  s.description = "Uses a pub/sub channel for broadcasting SELECT queries for replay onto follower databases"
  s.license     = "MIT"

  s.add_development_dependency "rspec", "~> 2.13.0"

  s.files        = Dir.glob("{lib}/**/*") + %w(README.md LICENSE)
  s.require_path = "lib"
end
