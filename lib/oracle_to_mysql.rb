# A super robust process spawning lib, install via
#   gem install --remote --include-dependencies POpen4
#   See http://rubygems.org/gems/POpen4
#   and http://popen4.rubyforge.org/
#
require 'popen4'

# These commands are used internally to actuall do the work
require 'oracle_to_mysql/command'
require 'oracle_to_mysql/command/write_sqlplus_commands_to_file'
require 'oracle_to_mysql/command/fork_and_execute_sqlplus_command.rb'
require 'oracle_to_mysql/command/write_and_execute_mysql_commands_to_bash_file.rb'
require 'oracle_to_mysql/command/write_and_execute_mysql_commands_to_bash_file_in_replace_mode.rb'
require 'oracle_to_mysql/command/delete_temp_files.rb'


# a tool to help with referencing old tables and reflecting the retention strategy
#
require 'oracle_to_mysql/table_namer'
module OracleToMysql
  class CommandError < Exception; end
  class MustOverrideMethod < Exception; end
  class NoMysqlConfigSpecified < Exception; end
  class NoOracleConfigSpecified < Exception; end
  # used to join the table and timestamp for old retained tables if :n > 1, or if :n = 1 its simply the suffix of the table name
  OTM_RETAIN_KEY = '_old' 
  OTM_VALID_STRATEGIES = [:accumulative, :atomic_rename]
  
  module PrivateInstanceMethods
    def otm_set_strategy(strategy,options={})
      raise "Invalid strategy #{strategy}" unless OTM_VALID_STRATEGIES.include?(strategy)
      @otm_strategy = strategy
      # TODO: verify options
      @otm_strategy_options = options
    end
    
    def otm_started(msg)      
      self.otm_output("[started t=#{self.otm_time_elapsed_since_otm_timestamp}]#{msg}")
    end    
    def otm_finished(msg)
      self.otm_output("[finished t=#{self.otm_time_elapsed_since_otm_timestamp}]#{msg}")
    end
    # LOGGING FUNCTIONS END
        
    def otm_time_elapsed_since_otm_timestamp
      if @otm_timestamp.nil?
        self.otm_timestamp # calling this first, causes the lazily loaded timestamp to load...
        0
      else
        Time.now - self.otm_timestamp
      end
    end
    
    # This reflects on the various strategy, retain, and other options that the client class has specified
    # and generates a linear sequence of command names that will be executed
    # on .otm_execute
    #
    def otm_execute_command_names
      if @otm_execute_command_names.nil?
        case self.otm_strategy
        when :atomic_rename        
          @otm_execute_command_names = [
            :write_sqlplus_commands_to_file,
            :fork_and_execute_sqlplus_commands_file,
            :write_and_execute_mysql_commands_to_bash_file
          ]
        when :accumulative
          @otm_execute_command_names = [
            :write_sqlplus_commands_to_file,
            :fork_and_execute_sqlplus_commands_file,
            :write_and_execute_mysql_commands_to_bash_file_in_replace_mode
          ]
        else
          raise "Invalid otm_strategy=#{@otm_strategy}"
        end
        
        ## All strategies should cleanup after themselves lastly
        @otm_execute_command_names << :delete_temp_files
      end
      @otm_execute_command_names                  
    end         
    
    # This generates a temp file suffixed with the specified x
    # it is used  
    def generate_tmp_file_name(x)
      File.join(self.tmp_directory,"#{self.otm_target_table}_#{self.otm_timestamp.to_i}_#{self.object_id}_#{Process.pid}_#{x}")
    end
    
    def otm_verify_config
      unless self.otm_target_config_hash.kind_of?(Hash)
        raise NoMysqlConfigSpecified.new("[.otm_verify_confg][otm_target_config_hash not a hash]")
      end
      unless self.otm_source_config_hash.kind_of?(Hash)
        raise NoOracleConfigSpecified.new("[.otm_verify_confg][otm_source_config_hash not a hash]")
      end
      %w(username password host database).each do |k|
        if self.otm_target_config_hash[k].nil?
          raise NoMysqlConfigSpecified.new("[.otm_verify_confg][missing key #{k} in hash]")
        end
        if self.otm_source_config_hash[k].nil?
          raise NoOracleConfigSpecified.new("[.otm_verify_confg][missing key #{k} in hash]")
        end
      end
    end
  end  # PrivateInstanceMethods
  
  module ProtectedClassMethods
    def otm_default_post_mirror_options
      {:optimize_table => true}
    end    
    def otm_default_strategy
      :atomic_rename        # can also be :accumulative
    end
  end
  
  module OptionalOverrideInstanceMethods    
    
    # YOU WILL OFTEN WANT TO OVERRIDE THIS, 
    def otm_strategy
      if @otm_strategy.nil?
        @otm_strategy = self.class.otm_default_strategy
      end
      @otm_strategy      
    end
              
    # TO CHANGE the retain options, override this method
    #    
    def otm_retain_options
      if @otm_retain_options.nil?
        @otm_retain_options = {:n => 1} 
      end
      @otm_retain_options
    end
    
    # This results in mysql queries executing afterwords that optimize the table
    # and get it set for prime time usage...
    #
    def otm_post_mirror_options
      if @otm_post_mirror_options.nil?
        @otm_post_mirror_options = self.class.otm_default_post_mirror_options
      end
      @otm_post_mirror_options      
    end
        
    # The options hash can contain :classification => <SYMBOL> which can be used
    # when overriding otm_output
    #
    def otm_output(msg, options={})
      puts "[#{self.to_s}]#{msg}"
    end        
    
    def otm_source_config_hash
      if self.otm_config_hash.has_key?('oracle_source')
        return otm_config_hash['oracle_source']
      else
        raise NoOracleConfigSpecified.new("You should either add a oracle_source entry to #{self.otm_config_file} or override otm_source_config_hash")
      end
    end
    
    def otm_target_config_hash
      if self.otm_config_hash.has_key?('mysql_target')
        return otm_config_hash['mysql_target']
      else        
        raise NoMysqlConfigSpecified.new("You should either add a mysql_target entry to #{self.otm_config_file} or override otm_target_config_hash")
      end      
    end
    
    # Override this if you have zany rules about where your config file is, there is a handy otm_config_hash method in the ApiInstanceMethods
    # you can use to get stuff outta here
    #
    def otm_config_file
      non_rails_path = File.join(Dir.pwd, 'oracle_to_mysql.yml')
      if defined?(RAILS_ROOT)
        rails_path = File.join(RAILS_ROOT,'config','database.yml')
        if rails_path
          @otm_db_config_yml_file_name = rails_path
        else
          raise "Weird, RAILS_ROOT detected but no databases.yml, something is amiss!"
        end
      elsif File.exists?(non_rails_path)
        @otm_db_config_yml_file_name = non_rails_path
      else
        raise "ERROR: No otm config file found"
      end
    end  
    
    def otm_table_namer
      # Its important that this only instantiates once, so the dates/timestamps are consistent
      if @otm_table_namer.nil?
        @otm_table_namer = TableNamer.new(self.otm_target_table, :now => self.otm_timestamp)
      end
      @otm_table_namer
    end

    def tmp_directory
      "/tmp"  
    end                                       
  end
  
  module MustOverrideInstanceMethods    
    def otm_source_sql
      raise MustOverrideMethod.new("must override otm_source_sql, this is the oracle sql")
    end
    def otm_target_sql
      raise MustOverrideMethod.new("must override otm_target_sql, this is the create table mysql statement")
    end
    def otm_target_table
      raise MustOverrideMethod.new("must override otm_target_table, this is the final mysql table name of the mysql target ")
    end  
  end
  
  
  module ApiInstanceMethods
    def otm_execute
      self.otm_verify_config      
      self.otm_output("[started at #{self.otm_timestamp}]")
      self.otm_started("#otm_execute (in #{self.otm_strategy.to_s} mode, retain_n = #{self.otm_retain_options[:n]}")
      self.otm_execute_command_names.each do |command_name|
        command = OracleToMysql.get_and_bind_command(command_name, self)
        begin
          command.execute
        rescue OracleToMysql::CommandError => e
          raise e           
        rescue Exception => e
          raise e
        end        
      end
      self.otm_finished("#otm_execute")
      final_time_elapsed = self.otm_time_elapsed_since_otm_timestamp
      finished_at = self.otm_timestamp + final_time_elapsed
      
      self.otm_output("[finished at #{finished_at}]")
      self.otm_output("[completed in #{final_time_elapsed} seconds]")
      self.otm_reset_timestamp
      return true
    end
    
    # This is used extensively by commands to read and write the the specific files
    # that are shared accross commands, it is a bit protected-ish though (aka prolly don't want to override this)
    #
    def otm_get_file_name_for(sym)
      f = self.generate_tmp_file_name(sym)
      case sym
      when :mysql_commands, :oracle_commands
        "#{f}.sql"   # sqlplus is such a jackass, the file name must end in .sql for it to work, fyi
      when :oracle_output
        "#{f}.txt"
      else
        raise "Invalid file_name #{sym}"
      end
    end
    
    # For interaction with the configuration file that contains the mysql or oracle stuff
    # override otm_config_file if you have yer config somewhere crazy
    #
    def otm_config_hash
      if @otm_confile_file_hash.nil?
        @otm_confile_file_hash = YAML.load(File.read(self.otm_config_file))
      end
      @otm_confile_file_hash      
    end
    
    # all tables and file name are versioned against the seconds of this Time obj
    #
    def otm_timestamp
      if @otm_timestamp.nil?
        @otm_timestamp = Time.now
      end
      @otm_timestamp
    end
    
    # You need to do this to invoke .otm_execute twice on the same inst, or it will clobber
    def otm_reset_timestamp
      @otm_timestamp = nil # reset it so all temp files have a new identifier, if otm_execute'd is executed again
    end
    
    # Returns all temp files that all commands in the current strategy can create
    #
    def otm_all_temp_files
      return_this = []
      self.otm_execute_command_names.each do |command_name|
        command = OracleToMysql.get_and_bind_command(command_name, self)
        return_this += command.temp_file_symbols.map {|sym| self.otm_get_file_name_for(sym)}
      end
      return_this.uniq
    end
  end
  
  
  
  
  
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
  def self.tns_string_from_config(config_hash)     
    if config_hash['port'].nil?
      config_hash['port'] = 1521 # default oracle port
    end
      "(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=#{config_hash['host']})(PORT=#{config_hash['port']})))(CONNECT_DATA=(SERVICE_NAME=#{config_hash['database']})))"
  end  
end
