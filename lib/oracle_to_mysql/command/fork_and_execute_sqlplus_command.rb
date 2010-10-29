module OracleToMysql
  class Command
    class ForkAndExecuteSqlplusCommand < OracleToMysql::Command              
      def command_line_invocation
        username = self.client_class.otm_source_config_hash['username']
        password = self.client_class.otm_source_config_hash['password']
        tns = OracleToMysql.tns_string_from_config(self.client_class.otm_source_config_hash)   #self.client_class.otm_source_config_hash['tns']
        "sqlplus -S '#{username}/#{password}@#{tns}' @#{self.client_class.otm_get_file_name_for(:oracle_commands)}"      
      end

      # overridden from parent to help CleanupTempFilesAndTables do it's job
      # 
      def temp_file_symbols
        [:oracle_output]
      end
      
      def execute_internal
        stderr_str = ""
        stdout_str = ""     
        the_command = self.command_line_invocation
        self.started("sqlplus child being spawned")
        unless
          Open4::popen4(the_command) { |pid, stdin, stdout, stderr|
            stderr_str = stderr.read
            stdout_str = stdout.read
            true
          }
          self.error("Could not execute #{the_command}")
          # raise "[#{self.to_s}][create_#{deriv_type.to_s}_with_convert][MBF##{mbf.id.to_s}] Couldn't execute #{convert_cmd}"
        end
        self.finished("sqlplus process terminated")

        if stderr_str.length > 0
          self.error("sqlplus had stderr output: #{stderr_str}")
        end
        if stdout_str.length > 0
          self.warn("sqlplus had stdout output: #{stdout_str}")
        end

        if File.exists?(self.client_class.otm_get_file_name_for(:oracle_output))
          spooled_file_size = File.size(self.client_class.otm_get_file_name_for(:oracle_output))
          sqlplus_file_size = File.size(self.client_class.otm_get_file_name_for(:oracle_commands))

          # This sqlplus file will have the oracle message
          if spooled_file_size > sqlplus_file_size
            self.info("sqlplus spooled #{spooled_file_size} bytes of output to #{self.client_class.otm_get_file_name_for(:oracle_output)}")
          else
            source_output_contents = IO.read(self.client_class.otm_get_file_name_for(:oracle_output))          
            self.warn("tiny data output: smaller than the sqlplus commands file, #{spooled_file_size} bytes, it might contains errors rather than data, I will check for Oracle error strings in #{self.client_class.otm_get_file_name_for(:oracle_output)} and die if so")
            if source_output_contents.match(/^ERROR at line/) && source_output_contents.match(/^ORA-/)
              self.error("sqlplus error: #{self.client_class.otm_get_file_name_for(:oracle_output)} contains both \"ERROR at line\" and \"ORA-\" in it, check it out, contents=#{source_output_contents}")            
            end          
          end
        else
          self.error("#{self.client_class.otm_get_file_name_for(:oracle_output)} does not exist")
        end
        self.info("sqlplus returned successfully")      
      end
    end
  end
end