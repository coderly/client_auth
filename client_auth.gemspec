# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'client_auth/version'

Gem::Specification.new do |spec|
  spec.name          = "client_auth"
  spec.version       = ClientAuth::VERSION
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
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "factory_girl"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "hashie"
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'database_cleaner'
  spec.add_development_dependency 'timecop' 
    
  spec.add_dependency("activerecord", "~> 4.1.1")
  spec.add_dependency("activesupport", "~> 4.1.1")
  spec.add_dependency("grape")
  spec.add_dependency("bcrypt")  
  
end
