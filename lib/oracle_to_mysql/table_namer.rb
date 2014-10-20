module OracleToMysql
  class TableNamer
    attr_accessor :table_name, :now
    def initialize(table_name,*args)
      options = args.first || {}
      @table_name = table_name 
      @now = options[:now] || Time.now
    end

    def yesterday
      tt=(self.now - 24 * 60 * 60).strftime('%Y%m%d')
      "old_#{tt}_#{self.table_name}"
    end
    def temp
      tt=self.now.to_i
      "temp_#{tt}_#{self.table_name}"
    end

    def old_table_sql_like_wildcard
      # When using a LIKE clause, we have to escape underscores or they'll be 
      # interpreted as a single-character wildcard. The 8 unescaped underscores
      # match the date in the table name. Using a '%' here can cause overlap
      # can delete tables you want to keep!
      # http://dev.mysql.com/doc/refman/5.0/en/string-comparison-functions.html#operator_like
      "old\\_________\\_#{self.table_name.gsub('_', '\_')}"
    end

    # list old tables, newest first
    def sql_for_old_tables(schema, options={:offset => 0})
      # http://stackoverflow.com/questions/255517/mysql-offset-infinite-rows for limit statement details
      "
      SELECT 
         table_name 
       FROM information_schema.tables 
       WHERE 
         table_name LIKE '#{old_table_sql_like_wildcard}' 
         AND table_schema = '#{schema}'
       ORDER BY table_name DESC
       LIMIT #{options[:offset]}, 18446744073709551615
      "
    end 
  end
end
