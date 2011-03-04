module OracleToMysql
  class Command
    class DropOldTables < OracleToMysql::Command
      def execute_internal
        h =self.client_class.otm_target_config_hash
        # Create MySQL connection via host or socket
        if h.has_key?(:socket)
          self.info("Connecting with mysql gem via socket")
          conn = Mysql.new(
            nil, # no host
            h['username'],
            h['password'],
            h['database'],
            nil, # no port
            h[:socket]
          )
        else
          self.info("Connecting with mysql gem via TCP")
          conn = Mysql.new(
            h['host'], 
            h['username'],
            h['password'],
            h['database'],
            h['port']
          )
        end

        old_tables_to_drop = conn.query(
          self.client_class.otm_table_namer.sql_for_old_tables(h['database'], :offset => self.client_class.otm_number_of_tables_to_retain)
        )
        self.info("Dropping old tables, will retain #{self.client_class.otm_number_of_tables_to_retain}")
        while row = old_tables_to_drop.fetch_hash do
          conn.query("drop table #{row['table_name']}")  
          self.info("Dropped #{row['table_name']}")
        end
      end
    end      
  end
end
