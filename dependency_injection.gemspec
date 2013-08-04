$LOAD_PATH.unshift(File.expand_path('../lib', __FILE__))
require 'dependency_injection/version'

Gem::Specification.new do |spec|
  spec.name          = 'dependency_injection'
  spec.version       = DependencyInjection::VERSION
  spec.summary       = 'Dependency Injection system for Ruby'
  spec.description   = 'A fully customizable Dependency injection system for Ruby'
  spec.homepage      = 'https://github.com/kdisneur/dependency_injection'
  spec.license       = 'MIT'
  spec.authors       = ['Kevin Disneur']
  spec.email         = 'kevin@koboyz.org'
  spec.files         = `git ls-files`.split($/)
  spec.require_paths = %w(lib)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})

  spec.add_dependency('activesupport')
end
