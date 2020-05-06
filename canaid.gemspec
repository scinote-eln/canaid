$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'canaid/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'canaid'
  s.version     = Canaid::VERSION
  s.authors     = ['sciNote LLC', 'BioSistemika LLC', 'Luka Murn']
  s.email       = ['info@scinote.net', 'info@biosistemika.com', 'murn.luka@gmail.com']
  s.homepage    = 'https://github.com/biosistemika/canaid'
  s.summary     = 'Ruby authorization helper library.'
  s.description = 'Canaid is yet another Ruby authorization library.'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  s.add_dependency 'devise', '>= 4.6.2', '< 4.8.0'
  s.add_dependency 'docile', '>= 1.1.0'
  s.add_dependency 'rails', '~> 5.2.3'
  s.add_development_dependency 'rspec'
end
