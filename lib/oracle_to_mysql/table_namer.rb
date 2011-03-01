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
      "old_%_#{self.table_name}"
    end

    # list old tables, newest first
    def sql_for_old_tables(schema)
      "
      SELECT 
         table_name 
       FROM information_schema.tables 
       WHERE 
         table_name LIKE '#{old_table_sql_like_wildcard}' 
         AND table_schema = '#{schema}'
       ORDER BY table_name DESC
      "
    end 
  end
end

# module TableNamer





#   class NoTableNamerOptionsMethodDefined < Exception; end
#   class TableNamerOptionsMustBeKindOfHash < Exception; end
#   class Base
#     attr_accessor :name, :schema, :now, :prefix, :glue, :series_mode
#     def initialize
#       @name = "MUST_SPECIFY"
#       @schema = "MUST_SPECIFY"
#       # Set defaults
#       @prefix = ""
#       @glue = "_"
#       @now = Time.now
#       @series_mode = :date_prefixed
#     end

#     def timestamp_prefixed(*args)
#       self.join_em([self.prefix, self.now.to_i, self.name])
#     end

#     def date_prefixed(*args)
#       self.join_em([self.prefix, self.now.strftime("%Y%m%d"), self.name])
#     end
    
#     def temp
#     end

#     def series(*args)
#       options = args.first || {}
#       options[:length] ||= 10
#       options[:direction] ||= :backward
#       count = 0
#       r = []
#       now_interval = case self.series_mode
#       when :date_prefixed
#         86400  # 60 * 60 * 24, seconds in a day
#       else
#         raise "invalid method, #{meth}"
#       end
#       p = self
#       while count < options[:length]
#         new_time = if options[:direction] == :backward
#           p.now - now_interval 
#         elsif options[:direction] == :forward
#           p.now + now_interval 
#         else
#           raise "invalid direction, #{options[:direction]}"
#         end
#         p = p.clone
#         p.now = new_time
#         r << p.send(self.series_mode) 
#         count += 1
#       end
#       r
#     end

#     def mysql_for_series(*args)
#       options = args.first || {}
#       order_by = options[:direction] == :backward ? "DESC" : "ASC"
#       tables = self.series(*args)
#       "SELECT 
#          table_name 
#        FROM 
#          information_schema.tables 
#        WHERE 
#          table_name IN ('#{tables.join("','")}')
#          AND table_schema = 'warehouse'
#        ORDER BY table_name #{order_by}
#       "  
#     end

#     protected
#       def join_em(elements,*args)
#         elements.delete_if {|x| x.nil? || x == ""}
#         t=elements.join(self.glue)
#         "#{self.schema}.#{t}"
#       end
#   end
#   # def self.included(caller)
#   #   caller.class_eval do
#   #     include InstanceMethods
#   #   end
#   # end 

#   # module InstanceMethods
#   #   def table_namer
#   #     if @table_namer.nil?
#   #       if self.respond_to? :table_namer_options
#   #         @table_namer = TableNamer::Base.new
#   #         options = self.table_namer_options
#   #         if options.kind_of? Hash
#   #           options.each_pair do |key,val|
#   #             if val.kind_of? Symbol # its an instance method name, call it
#   #               @table_namer.send("#{key}=",self.send(val))
#   #             else
#   #               @table_namer.send("#{key}=",val)
#   #             end
#   #           end
#   #         else
#   #           raise TableNamerOptionsMustBeKindOfHash.new("Come on now, your table_namer_options method must return a Hash")
#   #         end
#   #       else
#   #         raise NoTableNamerOptionsMethodDefined.new("You must define a table_namer_options instance method")
#   #       end
#   #     end  
#   #     @table_namer
#   #   end
#   # end
 
# end
