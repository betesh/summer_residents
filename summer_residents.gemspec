$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "summer_residents/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "summer_residents"
  s.version     = SummerResidents::VERSION
  s.authors     = ["Isaac Betesh"]
  s.email       = ["iybetesh@gmail.com"]
  s.homepage    = "http://www.github.com/betesh/summer_residents"
  s.summary     = "A user data resources engine for bungalow colony CRMs"
  s.description = `cat README.rdoc`

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.8"
  s.add_dependency "easy_rails_authentication", "~> 0.0.4"
  # s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
end
