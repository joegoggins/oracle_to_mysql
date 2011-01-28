module OracleToMysql
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
    
    # Must pass an argument, retain_n is "the number tables old relative to the current table"
    # if n is 1, the retained table is simple <TBL>_old
    # if its greater, there a dynamic "show retained tables for this table", sort lexically, 
    # and return the -nth retain_n (i think) (negative nth) from the list
    #
    def otm_retained_target_table(retain_n)
      if retain_n == 1
        "#{self.otm_target_table}#{OTM_RETAIN_KEY}"
      else
        raise "TODO: HAVE NOT DEALT WITH n != 1 retain option"
      end
    end
    
  end
end
