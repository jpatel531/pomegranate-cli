# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pomegranate/cli/version'

Gem::Specification.new do |spec|
  spec.name          = "pomegranate-cli"
  spec.version       = Pomegranate::Cli::VERSION
  spec.authors       = ["jpatel531"]
  spec.email         = ["jamie@notespublication.com"]
  spec.summary       = %q{Part of the Pomegranate project}
  spec.description   = %q{A command-line interface for creating a pomegranate.json file}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = ["pomegranate"]
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_runtime_dependency "commander", ">= 4.2.1"
  spec.add_runtime_dependency "colorize"
end
