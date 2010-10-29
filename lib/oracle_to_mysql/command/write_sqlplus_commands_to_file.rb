module OracleToMysql
  class Command
    class WriterSqlplusCommandsToFile < OracleToMysql::Command
      def string_to_write_commands_file_name
        # strip out an trailing ; or whitespace at the end...this sqlplus will barf otherwise or not-execute the command        
        the_source_sql = self.client_class.otm_source_sql.gsub(/;\s*$/,'').strip 
        the_file_to_spool_output_to = self.client_class.otm_get_file_name_for(:oracle_output)
        return "
            WHENEVER SQLERROR EXIT 2;
            spool on;
            set heading off
            set echo off
            set verify off
            set termout off
            SET NEWPAGE 0;
            SET SPACE 0;
            SET PAGESIZE 0;
            SET FEEDBACK OFF;
            SET TRIMSPOOL ON;
            SET TAB OFF;
            set linesize 2000;
            spool #{the_file_to_spool_output_to}
            #{the_source_sql};
            spool off;
            exit;          
            "      
      end
      # overridden from parent to help CleanupTempFilesAndTables do it's job
      # 
      def temp_file_symbols
        [:oracle_commands]
      end
      
      def execute_internal
        bytes_written = 0      
        File.open(self.client_class.otm_get_file_name_for(:oracle_commands),'w') do |f|        
          bytes_written = f.write(self.string_to_write_commands_file_name)
        end
        if bytes_written > 0
          self.info("#{bytes_written} bytes written to #{self.client_class.otm_get_file_name_for(:oracle_commands)}")
        else
          self.error("could not write to #{self.client_class.otm_get_file_name_for(:oracle_commands)}, bytes_written=#{bytes_written}")
        end
      end
    end         
  end
end