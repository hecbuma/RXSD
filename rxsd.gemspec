GEM_NAME="rxsd"
PKG_VERSION='0.5.2'

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.name = GEM_NAME
  s.version = PKG_VERSION
  s.author = 'Mo Morsi'
  s.email = 'mo@morsi.org'
  s.date = Date.today.to_s
  s.description = %q{A library to translate xsd schemas and xml implementations into ruby classes/objects}
  s.summary = %q{A library to translate xsd schemas and xml implementations into ruby classes/objects}
  s.homepage = %q{http://morsi.org/projects/RXSD}

  s.files = `git ls-files`.split($/)
  s.executables << 'xsd_to_ruby' << 'rxsd_test'

  s.required_ruby_version = '>= 2.0.0'

  s.add_dependency('libxml-ruby', '~> 2.8.0')
  s.add_dependency('activesupport', '~> 4.2.5')
  s.add_development_dependency 'bundler', '~>1.11'
  s.add_development_dependency 'rake', '~>10.0'
  s.add_development_dependency 'minitest', '~>5.0'
  s.add_development_dependency 'rubocop', '~>0.37'
  s.add_development_dependency 'yard', '~>0.8'
  s.add_development_dependency 'yardstick', '~>0.9'


end
