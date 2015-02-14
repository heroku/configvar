# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'configvar/version'

Gem::Specification.new do |spec|
  spec.name          = 'configvar'
  spec.version       = ConfigVar::VERSION
  spec.authors       = ['jkakar']
  spec.email         = ['jkakar@kakar.ca']
  spec.description   = 'Manage configuration loaded from the environment'
  spec.summary       = 'Manage configuration loaded from the environment'
  spec.homepage      = 'https://github.com/heroku/configvar'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep('^(test|spec|features)/')
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'rake'
end
