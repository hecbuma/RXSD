GEM_NAME="rxsd"
PKG_VERSION='0.5.3'

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.name = GEM_NAME
  s.version = PKG_VERSION
  s.files = `git ls-files`.split($/)
  s.executables << 'xsd_to_ruby' << 'rxsd_test'

  s.required_ruby_version = '>= 1.8.1'
  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.3")

  s.add_dependency('libxml-ruby', '~> 2.8.0')
  s.add_dependency('activesupport', '~> 4.2.5')

  s.add_development_dependency 'rspec', '~> 3.4.0'
  s.add_development_dependency 'guard'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'pry-remote'
  s.add_development_dependency 'pry-nav'
  s.add_development_dependency 'pry-byebug'
  s.add_development_dependency 'rake'

  s.author = 'Mo Morsi'
  s.email = 'mo@morsi.org'
  s.date = Date.today.to_s
  s.description = %q{A library to translate xsd schemas and xml implementations into ruby classes/objects}
  s.summary = %q{A library to translate xsd schemas and xml implementations into ruby classes/objects}
  s.homepage = %q{http://morsi.org/projects/RXSD}
end
