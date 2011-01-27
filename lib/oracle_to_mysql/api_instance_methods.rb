module OracleToMysql
  module ApiInstanceMethods
    def otm_execute
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
        
    # returns an array of all target tables by reflecting the table retention options
    #
    def otm_all_target_tables
      return_this = [self.otm_target_table]
      if self.otm_retain_options[:n] == 0
        return_this
      else
        (1..self.otm_retain_options[:n]).to_enum.each do |x|
          return_this << self.otm_retained_target_table(x)
        end
        return_this
      end
    end
  end
end
