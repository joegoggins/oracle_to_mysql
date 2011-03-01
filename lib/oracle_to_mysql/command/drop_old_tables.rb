module OracleToMysql
  class Command
    class DropOldTables < OracleToMysql::Command
      def execute_internal
        h =self.client_class.otm_target_config_hash
        conn = Mysql.new(
          h['host'], # no host
          h['username'],
          h['password'],
          h['database'],
          h['port']
        )

        old_tables_results = conn.query(self.client_class.otm_table_namer.sql_for_old_tables(h['database']))
        count = 0
        self.info("Dropping old tables, will retain #{self.client_class.otm_number_of_tables_to_retain}")
        while row = old_tables_results.fetch_hash do
          if count < self.client_class.otm_number_of_tables_to_retain
            self.info("Not dropping #{row['table_name']}")
            # Do nothing, this table should be retained
          else
            conn.query("drop table #{row['table_name']}")  
            self.info("Dropped #{row['table_name']}")
          end
          count += 1 
        end
      end
    end      
  end
end
