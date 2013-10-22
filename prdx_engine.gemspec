# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'prdx_engine/version'

Gem::Specification.new do |spec|
  spec.name          = "prdx_engine"
  spec.version       = PrdxEngine::VERSION
  spec.authors       = ["Denis Mingulov"]
  spec.email         = ["denis@mingulov.com"]
  spec.description   = %q{Library to work with different file formats}
  spec.summary       = %q{Library to work with different file formats}
  spec.homepage      = "http://github.com/mingulov/prdx_engine"
  spec.license       = "MIT"

  spec.required_ruby_version = '>= 1.9'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.extensions    = spec.files.grep(%r{/extconf.rb$})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 2.6"
  spec.add_development_dependency "rake-compiler"
end
