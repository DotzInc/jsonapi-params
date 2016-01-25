# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jsonapi/params/version'

Gem::Specification.new do |spec|
  spec.name          = "jsonapi-params"
  spec.version       = JSONAPI::Params::VERSION
  spec.authors       = ["Noverde Team"]
  spec.email         = ["dev@noverde.com.br"]

  spec.description   = %q{Gem to handle with parameters according to jsonapi specification}
  spec.homepage      = "https://github.com/Noverde/jsonapi-params"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
