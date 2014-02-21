# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'devices_auth/version'

Gem::Specification.new do |spec|
  spec.name          = "devices_auth"
  spec.version       = DevicesAuth::VERSION
  spec.authors       = ["Israel De La Hoz"]
  spec.email         = ["israeldelahoz@gmail.com"]
  spec.description   = %q{this gem enables several devices authentication for apis}
  spec.summary       = %q{ authenticate by device and enable current device}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  
  spec.add_dependency("activerecord", "~> 4.0.1")
  
  
end
