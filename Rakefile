require 'rake/gempackagetask'

spec = Gem::Specification.new do |s|
  s.name = "xbrlparser"
  s.summary = "An XBRL instance document parser."
  s.description= "An XBRL instance document parser."
  s.requirements = [ 'None' ]
  s.version = "0.0.1"
  s.author = "David Ellis"
  s.email = "davidkellis@gmail.com"
  s.homepage = "http://david.davidandpenelope.com"
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>=1.9'
  s.files = Dir['**/**']
  s.executables = []
  s.test_files = []
  s.has_rdoc = false
  
  s.add_runtime_dependency 'leiri'
  s.add_runtime_dependency 'xpointer'
  s.add_runtime_dependency 'nokogiri'
end

Rake::GemPackageTask.new(spec).define