# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "oracle_to_mysql/version"

Gem::Specification.new do |s|
  s.name = "oracle_to_mysql"
  s.version = "1.1.0"
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Joe Goggins", "Chris Dinger"]
  s.date = "2011-02-28"
  s.description = "Wraps the sqlplus binary and mysql binary does not currently require OCI8 or MySQL gems (might someday tho)"
  s.email = "joe.goggins@umn.edu"

  s.rubyforge_project = "oracle_to_mysql"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
  s.add_runtime_dependency "POpen4"
  s.add_runtime_dependency "mysql"
  s.add_development_dependency "shoulda"
end
