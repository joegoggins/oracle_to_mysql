# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{oracle_to_mysql}
  s.version = "1.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Joe Goggins", "Chris Dinger"]
  s.date = %q{2011-02-28}
  s.description = %q{Wraps the sqlplus binary and mysql binary does not currently require OCI8 or MySQL gems (might someday tho)}
  s.email = %q{joe.goggins@umn.edu}
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = [
    ".document",
    ".specification",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "lib/oracle_to_mysql.rb",
    "lib/oracle_to_mysql/command.rb",
    "lib/oracle_to_mysql/command/delete_temp_files.rb",
    "lib/oracle_to_mysql/command/fork_and_execute_sqlplus_command.rb",
    "lib/oracle_to_mysql/command/write_and_execute_mysql_commands_to_bash_file.rb",
    "lib/oracle_to_mysql/command/write_and_execute_mysql_commands_to_bash_file_in_replace_mode.rb",
    "lib/oracle_to_mysql/command/write_sqlplus_commands_to_file.rb",
    "oracle_to_mysql.gemspec",
    "test/demo/ps_term_tbl.rb",
    "test/demo/ps_term_tbl_accumulative.rb",
    "test/demo/test_oracle_to_mysql_against_ps_term_tbl.rb",
    "test/helper.rb",
    "test/oracle_to_mysql.example.yml",
    "test/test_against_ps_term_tbl_accumulative.rb",
    "test/test_oracle_to_mysql.rb"
  ]
  s.homepage = %q{http://github.com/joegoggins/oracle_to_mysql}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.4.1}
  s.summary = %q{A gem for mirroring data from an oracle db to a mysql db}
  s.test_files = [
    "test/demo/ps_term_tbl.rb",
    "test/demo/ps_term_tbl_accumulative.rb",
    "test/demo/test_oracle_to_mysql_against_ps_term_tbl.rb",
    "test/helper.rb",
    "test/test_against_ps_term_tbl_accumulative.rb",
    "test/test_oracle_to_mysql.rb"
  ]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<POpen4>, [">= 0"])
      s.add_development_dependency(%q<thoughtbot-shoulda>, [">= 0"])
    else
      s.add_dependency(%q<POpen4>, [">= 0"])
      s.add_dependency(%q<thoughtbot-shoulda>, [">= 0"])
    end
  else
    s.add_dependency(%q<POpen4>, [">= 0"])
    s.add_dependency(%q<thoughtbot-shoulda>, [">= 0"])
  end
end

