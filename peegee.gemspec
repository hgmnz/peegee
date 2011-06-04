# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "peegee/version"

Gem::Specification.new do |s|
  s.name        = "peegee"
  s.version     = Peegee::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Harold Giménez"]
  s.email       = ["hgimenez@thoughtbot.com"]
  s.homepage    = "http://github.com/peegee"
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.add_dependency 'activerecord'
  s.add_development_dependency 'cucumber'
  s.add_development_dependency 'aruba'
  s.add_development_dependency 'rspec-core'
  s.add_development_dependency 'rspec-expectations'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
