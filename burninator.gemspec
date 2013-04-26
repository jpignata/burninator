Gem::Specification.new do |s|
  s.name        = "burninator"
  s.version     = "1.0.0"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["John Pignata"]
  s.email       = ["john@pignata.com"]
  s.homepage    = "http://github.com/jpignata/burninator"
  s.summary     = "Keep your follower database warm"
  s.description = "Plays SELECT queries to your Rails application on a follower database to keep its caches warm."
  s.license     = "MIT"

  s.add_dependency "rails", ">= 3.2.0"
  s.add_dependency "redis", "~> 3.0.3"
  s.add_development_dependency "mocha", "~> 0.13.3"

  s.files        = Dir.glob("{lib}/**/*") + %w(README.md LICENSE)
  s.require_path = "lib"
end
