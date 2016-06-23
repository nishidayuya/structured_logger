# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'structured_logger/version'

Gem::Specification.new do |spec|
  spec.name          = "structured_logger"
  spec.version       = StructuredLogger::VERSION
  spec.authors       = ["Yuya.Nishida."]
  spec.email         = ["yuya@j96.org"]
  spec.summary       = "A structured logger with Ruby's Logger interface."
  spec.homepage      = "https://github.com/nishidayuya/structured_logger"
  spec.license       = "X11"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "listen", "~> 3.0.3"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "guard-bundler"
  spec.add_development_dependency "guard-test"
  spec.add_development_dependency "mocha"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "codeclimate-test-reporter"
  spec.add_development_dependency "activesupport"
end
