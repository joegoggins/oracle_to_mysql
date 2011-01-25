# A super robust process spawning lib, install via
#   gem install --remote --include-dependencies POpen4
#   See http://rubygems.org/gems/POpen4
#   and http://popen4.rubyforge.org/
#
require 'popen4'
require 'oracle_to_mysql/protected_class_methods'
require 'oracle_to_mysql/private_instance_methods'
require 'oracle_to_mysql/must_override_instance_methods'
require 'oracle_to_mysql/optional_override_instance_methods'
require 'oracle_to_mysql/api_instance_methods'

# These commands are used internally to actuall do the work
require 'oracle_to_mysql/command'
require 'oracle_to_mysql/command/write_sqlplus_commands_to_file'
require 'oracle_to_mysql/command/fork_and_execute_sqlplus_command.rb'
require 'oracle_to_mysql/command/write_and_execute_mysql_commands_to_bash_file.rb'
require 'oracle_to_mysql/command/write_and_execute_mysql_commands_to_bash_file_in_replace_mode.rb'
require 'oracle_to_mysql/command/delete_temp_files.rb'

module OracleToMysql
  class CommandError < Exception; end
  # used to join the table and timestamp for old retained tables if :n > 1, or if :n = 1 its simply the suffix of the table name
  OTM_RETAIN_KEY = '_old' 
  OTM_VALID_STRATEGIES = [:accumulative, :atomic_rename]


  # Stuff mixed into a client class calling include OracleToMysql
  def self.included(caller)
    caller.class_eval do
      private   
      include PrivateInstanceMethods          
      
      protected
      extend  ProtectedClassMethods

      # All customization will come by overriding methods in these classes
      include OptionalOverrideInstanceMethods   # You might need to override one or two of these
      include MustOverrideInstanceMethods       # THIS IS WHAT A CLIENT MUST OVERRIDE for .otm_execute to work
      
      public
      include ApiInstanceMethods                # You shouldn't need to override these, probably better to override at a lower level
    end
  end
  
  # If you add to this, don't forget to add the :my_command_name to otm_execute_command_names (and the class definition file)
  # and the require statement at the top of this class
  #
  def self.command_name_to_class_hash
    return {
      :write_sqlplus_commands_to_file => OracleToMysql::Command::WriterSqlplusCommandsToFile,
      :fork_and_execute_sqlplus_commands_file => OracleToMysql::Command::ForkAndExecuteSqlplusCommand,
      :write_and_execute_mysql_commands_to_bash_file => OracleToMysql::Command::WriteAndExecuteMysqlCommandsToBashFile,
      :write_and_execute_mysql_commands_to_bash_file_in_replace_mode => OracleToMysql::Command::WriteAndExecuteMysqlCommandsToBashFileInReplaceMode,
      # TODO pack-keys and optimize table
      :delete_temp_files => OracleToMysql::Command::DeleteTempFiles
    }      
  end
  
  ####
  # This is a very handy method for debugging a single Command bound to a particular client class
  #
  # x=OracleToMysql.get_and_bind_command(:write_sqlplus_commands_to_file, PsTermTbl.new)
  # x.execute
  #
  # or can access any other helper methods on x
  #
  ###
  def self.get_and_bind_command(command_name,client_class)
    raise "invalid command name #{command_name}" unless self.command_name_to_class_hash.has_key?(command_name)
    command = self.command_name_to_class_hash[command_name].new
    command.client_class = client_class
    return command
  end
  
  # once again, sqlplus the jackass needs a "TNS string" to connect to it's stankin ass
  # this interpolates crap from a config hash, like host and port and database into it
  #
  def self.tns_string_from_config(config_hash)      "(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=#{config_hash['host']})(PORT=#{config_hash['port']})))(CONNECT_DATA=(SERVICE_NAME=#{config_hash['database']})))"
  end  
end