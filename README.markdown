OracleToMysql
=============
A fast, minimal, debuggable Ruby wrapper for `sqlplus` and `mysql` binary's that pulls
data out of an Oracle database and inserts it into MySQL.

Please contact us via github if you have interest in using this tool, though it works great for us,
it's rough around the edges with regard to installation.  If we know of folks who want to use it/contribute
we'll make a point of cleaning things up and pushing to github more regularly.

System Dependencies
-------------------
* POpen4 gem
* mysql gem
* sqlplus binary in $PATH
* mysql binary in $PATH

Usage
-----
    class TheMagicMirrorer
      include OracleToMysql

      def otm_source_sql
        "select 
           col || CHR(9) ||
           col || CHR(9) ||
           ...
         from table
         where ... Oracle statement"
      end

      def otm_target_table
        "a_mysql_table_name"
      end

      def otm_target_sql
        "create table if not exists #{self.otm_target_table} (... mysql statement   "
      end
    end

    x = TheMagicMirrorer.new
    x.otm_execute

Will mirror the contents of otm_source_sql into the table created by otm_target_sql.
The "|| CHR(9) ||" is Oracle sql code that tab deliminates the column content in
the spooled sqlplus SQL data output.  The Mysql "load data infile" command eats this output.

If you are using with Rails, it expects database.yml to have oracle_source and mysql_target entries to get the
db connect info, to override the names

TODO: More usage examples for the config options below

Configuration Options
---------------------
### Mirror Strategies
  :atomic_rename (Default)
    "load data infile" the spooled oracle tab deliminted data into a temp table first
    then atomically rename 
      current_target_table -> old_target_table AND
       new_temp_table -> new_target_table
  :accumulative
    "load data infile" directly into target_table replacing any existing
    rows in target when source data triggers "ON DUPLICATE KEY"

### Target Table Retention
Determines how many mysql target tables should be preserved.  By default it just keeps yesterdays

== Gem Development & Testing
TODO: Integrate Chris's more general and not brittle test cases

The "tests" aka demo's assume you have a ps_term_tbl in your Oracle db.
If you're running PeopleSoft at a University you'll probably have this...
Otherwise, the tests won't run, it's just meant as an example that works in our world.

You'll need the thoughtbot-shoulda gem if you want to develop/hack on this gem or run the tests

To run tests:
cd test
  ruby test_oracle_to_mysql_against_ps_term_tbl.rb
OR
  irb -r test_oracle_to_mysql_against_ps_term_tbl.rb
  # And monkey with the run time...all files in test/demo are loaded, you can tinker with them
  
This assumes you have a connection file in the test dir:
  oracle_to_mysql.yml
copy and populate from oracle_to_mysql.example.yml

== Note on Patches/Pull Requests
* Fork the project.
* Add files to test/demo/* that demonstrate how you are using the tool.
* Bugfixes = fork, fix, commit, pull request.
* New Features = let us know what yer thinkin, we might already be working on it

== A few things we'd like to work on soon
* <strike>retention policy of 0: don't keep yesterdays data (aka don't create *_old table in mysql)<strike>
* <strike>retention policy > 1: keep N mysql table copies around </strike>
* usage of a Logger object instead of stdout
* Better configuration of what happens when the otm_execute fails, not sure...some options might include
  * email someone a backtrace of the exception
  * log the exception backtrace to a table in the db
  * either cleanup + delete temp files or keep around (now it just leaves the temp files around)

== Known Issues
* Since source data is written to disk a tab delimintated file, if the source oracle data contains a \t character in might mess things up (none of our data has tabs so we haven't had problems)
* Add validations/checks for stuff in validate_otm_source_sql in write_sqlplus_commands_to_file.rb if you encounter goofy sqlplus errors
  Things that are not easily programmatically detectable ought just have an inline note i suppose


