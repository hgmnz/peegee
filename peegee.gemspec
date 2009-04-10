# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{peegee}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Harold A. Gimenez"]
  s.date = %q{2009-04-10}
  s.email = %q{harold.gimenez@gmail.com}
  s.extra_rdoc_files = [
    "README.textile"
  ]
  s.files = [
    "README.textile",
    "Rakefile",
    "VERSION.yml",
    "lib/peegee.rb",
    "lib/peegee/clustering.rb",
    "lib/peegee/constraint.rb",
    "lib/peegee/foreign_key.rb",
    "lib/peegee/index.rb",
    "lib/peegee/primary_key.rb",
    "lib/peegee/table.rb",
    "lib/peegee/unique_constraint.rb",
    "peegee.gemspec",
    "spec/peegee_spec.rb",
    "spec/spec_helper.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/hgimenez/peegee}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.requirements = ["A functioning PostgreSQL database, configured via ActiveRecord (for example, database.yml on a Rails project, or inline within your scripts)."]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{A set of utilities for doing PostgreSQL database related stuffs from ruby.}
  s.test_files = [
    "spec/peegee_spec.rb",
    "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activerecord>, [">= 0"])
    else
      s.add_dependency(%q<activerecord>, [">= 0"])
    end
  else
    s.add_dependency(%q<activerecord>, [">= 0"])
  end
end
