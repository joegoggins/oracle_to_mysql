module OracleToMysql
  class TableNamer
    attr_accessor :table_name, :now
    def initialize(table_name,*args)
      options = args.first || {}
      @table_name = table_name
      @now = options[:now] || Time.now
    end

    def yesterday
      "#{self.table_name}_old"
    end

    def temp
      tt=self.now.to_i
      "temp_#{tt}_#{self.table_name}"
    end

    # list old tables, newest first
    def sql_for_old_tables(schema, options={:offset => 0})
      # http://stackoverflow.com/questions/255517/mysql-offset-infinite-rows for limit statement details
      "
      SELECT
         table_name
       FROM information_schema.tables
       WHERE
         table_name LIKE '#{yesterday}'
         AND table_schema = '#{schema}'
       ORDER BY table_name DESC
       LIMIT #{options[:offset]}, 18446744073709551615
      "
    end
  end
end
