module OracleToMysql
  class Command
    class WriteAndExecuteMysqlCommandsToBashFile < OracleToMysql::Command

      def tables_to_retain
        self.client_class.otm_retain_options[:n]
      end
      
      # Done this way so the child, _in_replace_mode, can override this
      #
      def mysql_command_order
        [:execute_otm_target_sql,
         :execute_temp_file_modded_otm_target_sql,
         :load_data_infile,        
         :drop_expired_retained_tables,
         :reflect_post_mirror_option_to_optimize_table,
         :perform_atomic_rename_of_tables
        ]
      end
      
########## MYSQL queryies/commands BEGIN

      def execute_otm_target_sql
        self.client_class.otm_target_sql
      end

      # The client class should not have to know about otm_temp_target_table
      # this overrides it just for this instance so the otm_target_sql
      # gets the temp table name interpolated into it instead of the actual
      # this is done this way to support the non-atomic rename strategy as well (which does not create a temp table)
      #
      def execute_temp_file_modded_otm_target_sql      
        the_modded_client_class_inst = self.client_class.clone
        the_modded_client_class_inst.instance_eval(<<-EOS, __FILE__,__LINE__)
          def otm_target_table
            "#{self.client_class.otm_temp_target_table}"
          end
        EOS
        the_modded_client_class_inst.otm_target_sql
      end
      
      def load_data_infile
        "-- Rip through the oracle output data and insert into mysql
         load data local infile '#{self.client_class.otm_get_file_name_for(:oracle_output)}' 
         into table #{self.client_class.otm_temp_target_table}
         fields terminated by '\\t'
         lines terminated by '\\n'
        "
      end      
      
      def create_actual_target_table_if_it_doesnt_exist        
        # If this is the first run, the destination table won't exist yet.  If that's the 
        # case, create an empty table so the atomic rename works
        "create table if not exists #{self.client_class.otm_target_table} 
         select * from #{self.client_class.otm_temp_target_table} where 1=0"
      end
      
      def drop_expired_retained_tables
        raise "TODO: not implemented yet for retention :n != 1" if tables_to_retain != 1
         "drop table if exists #{self.client_class.otm_retained_target_table(tables_to_retain)}"
      end
      
      def reflect_post_mirror_option_to_optimize_table
        s = ''
        if self.client_class.otm_post_mirror_options[:optimize_table]
          s << "OPTIMIZE TABLE #{self.client_class.otm_temp_target_table}"
        end
        s
      end
      
      def perform_atomic_rename_of_tables
        raise "TODO: not implemented yet for retention :n != 1" if tables_to_retain != 1
        "RENAME table 
          #{self.client_class.otm_target_table} TO #{self.client_class.otm_retained_target_table(tables_to_retain)}, 
          #{self.client_class.otm_temp_target_table} TO #{self.client_class.otm_target_table}"
        # rename table #{self.otm_retained_target_table}
        # 
        # 
        # #{self.client_class.otm_target_table} to #{self.client_class.otm_target_table}_old, #{self.client_class.otm_temp_target_table} to #{self.client_class.otm_target_table};
        # 
      end
      
      
########## MYSQL queryies/commands END

      # -- Reflect the table retain options
      # #{drop_expired_retained_tables_sql};

      def the_mysql_commands
        the_queries = ''
        self.mysql_command_order.each do |mysql_command|
          the_queries << "-- #{mysql_command.to_s}\n" # to make debugging easier
          the_queries << self.send(mysql_command)
          the_queries << ";\n"
        end
        the_queries    
      end

      def command_line_invocation
        h = self.client_class.otm_target_config_hash
        "mysql -u'#{h['username']}' -h'#{h['host']}' -p'#{h['password']}' #{h['database']} < '#{self.client_class.otm_get_file_name_for(:mysql_commands)}'"
      end
      
      # overridden from parent to help CleanupTempFilesAndTables do it's job
      # 
      def temp_file_symbols
        [:mysql_commands]
      end
      
      def execute_internal
        bytes_written = 0
        the_mysql_commands_file = self.client_class.otm_get_file_name_for(:mysql_commands)
        File.open(the_mysql_commands_file,'w') do |f|
          bytes_written = f.write(self.the_mysql_commands)
        end
        if bytes_written > 0
          self.info("#{bytes_written} bytes written to #{the_mysql_commands_file}")
        else
          self.error("Could not write to #{the_mysql_commands_file}")
        end

        stderr_str = ""
        stdout_str = ""     
        the_command = self.command_line_invocation
        self.started("mysql child being spawned")
        unless
         Open4::popen4(the_command) { |pid, stdin, stdout, stderr|
           stderr_str = stderr.read
           stdout_str = stdout.read
           true
         }
         self.error("Could not execute #{the_command}")
        end
        self.finished("mysql child terminated")

        if stderr_str.length > 0
          self.error("mysql child process had stderr output: #{stderr_str}")
        end
        if stdout_str.length > 0
          self.warn("mysql child process: #{stdout_str}")
        end      
      end
    end      
  end
end