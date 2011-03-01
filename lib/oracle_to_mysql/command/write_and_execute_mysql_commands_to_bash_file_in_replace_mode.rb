# THIS IS THE WORKHORSE FOR otm_strategy = :accumulative
module OracleToMysql
  class Command
    class WriteAndExecuteMysqlCommandsToBashFileInReplaceMode < OracleToMysql::Command::WriteAndExecuteMysqlCommandsToBashFile
      
      # OVERRIDDEN 
      def mysql_command_order        
        [:execute_otm_target_sql,
         :drop_yesterdays_table,
         :copy_data_into_yesterdays_table,
         :load_data_infile,                # overridden in this class
         :reflect_post_mirror_option_to_optimize_table_for_replace_mode
        ]
      end
      
### MYSQL COMMANDS BEGIN      
      def copy_data_into_yesterdays_table 
        # This class is modded to change the target to yesterdays table
        # 
        the_modded_client_class_inst = self.client_class.clone
        the_modded_client_class_inst.instance_eval(<<-EOS, __FILE__,__LINE__)
          def otm_target_table
            "#{self.client_class.otm_table_namer.yesterday}"
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

      # OVERRIDDEN TO optimize the target, NOT the temp table
      #
      def reflect_post_mirror_option_to_optimize_table_for_replace_mode
        s = ''
        if self.client_class.otm_post_mirror_options[:optimize_table]
          s << "OPTIMIZE TABLE #{self.client_class.otm_table_namer.table_name}"
        end
        s
      end
### MYSQL COMMANDS END      
    end
  end
end
