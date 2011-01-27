module OracleToMysql
  class Command
    class WriteAndExecuteMysqlCommandsToBashFileInReplaceMode < OracleToMysql::Command::WriteAndExecuteMysqlCommandsToBashFile
      
      # OVERRIDDEN 
      def mysql_command_order        
        [:execute_otm_target_sql,
         :drop_expired_retained_tables,   # defined in parent
         :retention_policy_create_and_populate_tables,
         :load_data_infile,                # overridden in this class
         # TODO reflect post mirror options
        ]
      end
      
### MYSQL COMMANDS BEGIN      
            
      def retention_policy_create_and_populate_tables
        raise "TODO: not implemented yet for retention :n != 1" if self.tables_to_retain != 1
        the_modded_client_class_inst = self.client_class.clone
        the_modded_client_class_inst.instance_eval(<<-EOS, __FILE__,__LINE__)
          def otm_target_table
            "#{self.client_class.otm_retained_target_table(tables_to_retain)}"
          end
        EOS
        
        return_this = ''
        return_this << the_modded_client_class_inst.otm_target_sql
        return_this << ";\n"
        return_this << "-- Insert existing rows into the retention table\n"
        return_this << "INSERT INTO #{the_modded_client_class_inst.otm_target_table} SELECT * FROM #{self.client_class.otm_target_table}\n"
        return_this
      end
            
      # Mostly the same as parent class except:
      #   * the replace key word which will replace existing rows on the target when there are mysql duplicate key errors
      #     possible todo: support "ignore" instead of "replace" (i have no reason to do this)
      #   * it copied into the otm_target_table directly rather than the temp table
      #  
      def load_data_infile
        "-- Rip through the oracle output data and insert into mysql
         load data local infile '#{self.client_class.otm_get_file_name_for(:oracle_output)}' 
         replace
         into table #{self.client_class.otm_target_table}         
         fields terminated by '\\t'
         lines terminated by '\\n'
        "
      end

### MYSQL COMMANDS END      
    end
  end
end