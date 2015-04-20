# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'serial_spec/version'

Gem::Specification.new do |spec|
  spec.name          = "serial-spec"
  spec.version       = SerialSpec::VERSION
  spec.authors       = ["Blake Chambers"]
  spec.email         = ["chambb1@gmail.com"]
  spec.summary       = %q{A better way to rspec api requests.}
  spec.description   = %q{A better way to rspec api requests.}
  spec.homepage      = "http://github.com/blakechambers/serial-spec"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "inheritable_accessors", ">= 0.1.2"
  spec.add_runtime_dependency "activesupport",         ">= 3.2.0"
end
