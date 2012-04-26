# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','snipper/version.rb'])

spec = Gem::Specification.new do |s|
  s.name = 'snipper'
  s.version = Snipper::VERSION
  s.author = 'R.I.Pienaar'
  s.email = 'rip@devco.net'
  s.homepage = 'http://devco.net/'
  s.platform = Gem::Platform::RUBY
  s.summary = 'Snipper'
  s.description = "A Unix CLI centric snippet manager that produces static files"
# Add your other files here if you make them
  s.files = FileList["{README.md,COPYING,bin,lib}/**/*"].to_a
  s.require_paths << 'lib'
  s.has_rdoc = false
  s.bindir = 'bin'
  s.executables << 'snipper'
  s.add_development_dependency('rake')
  s.add_development_dependency('rdoc')
  s.add_dependency 'pygments.rb'
end
