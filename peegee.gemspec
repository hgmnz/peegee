# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "peegee/version"

Gem::Specification.new do |s|
  s.name        = "peegee"
  s.version     = Peegee::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Harold Giménez", "Mike Burns"]
  s.email       = ["hgimenez@thoughtbot.com"]
  s.homepage    = "http://github.com/peegee"
  s.summary     = %q{PostgreSQL extensions for ActiveRecord}
  s.description = %q{Introduces ActiveRecord to PostgreSQL, adding support for PostgreSQL specific features.}

  s.add_dependency 'activerecord'
  s.add_development_dependency 'pg'
  s.add_development_dependency 'cucumber'
  s.add_development_dependency 'aruba'
  s.add_development_dependency 'rspec-core'
  s.add_development_dependency 'rspec-expectations'
  s.add_development_dependency 'rails', '3.0.10'
  s.add_development_dependency 'ruby-debug'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
