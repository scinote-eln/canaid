$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "canaid/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "canaid"
  s.version     = Canaid::VERSION
  s.authors     = ["sciNote LLC"]
  s.email       = ["info@scinote.net"]
  s.homepage    = "http://www.scinote.net"
  s.summary     = "Authorization helper library."
  s.description = "Description of Canaid."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", ">= 4"
  s.add_dependency "devise", ">= 3.4.1"
end
