module OracleToMysql
  class Command
    class WriterSqlplusCommandsToFile < OracleToMysql::Command
      class MaxLineExceeded < Exception; end
      # Oracle and sqlplus is so finicky, this captures some of the errors I've come across,
      # it is not exhuastive
      def validate_otm_source_sql
        the_source_sql = self.client_class.otm_source_sql

        # last character minus white space must be a ";"
        raise "otm_source_sql not terminated with a ';'" if the_source_sql.strip[-1..-1] != ';'
  
        # Detect and prevent sqlplus from SP2-0027: Input is too long (> 2499 characters) - line ignored
        the_source_sql.each_line {|x| raise MaxLineExceeded.new("Ruby detection and prevention of Oracle error SP2-0027: Input is too long (> 2499 characters) - line ignored") if x.length > 2499}
        
        # other sqlplus CAVEATS (that could be programmed, TODO-ish)
        # If you're "IN" statements has more than 1000 elements, Oracle will barf out a ORA-01795 error
        # 
      end
      
      
      def string_to_write_commands_file_name
        self.validate_otm_source_sql
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
            #{self.client_class.otm_source_sql}
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