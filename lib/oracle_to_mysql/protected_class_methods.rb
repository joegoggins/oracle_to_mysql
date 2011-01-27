module OracleToMysql
  module ProtectedClassMethods
    def otm_default_post_mirror_options
      {:optimize_table => true}
    end    
    def otm_default_strategy
      :atomic_rename        # can also be :accumulative
    end
    
    # These options set what happens to an existing target if it exists
    # a retain value of n=1, means "keep the last table arround"
    # 
    def otm_default_retain_options
      return {
        :n => 1,
        :table_name_pattern => Proc.new {|dest_table| Regexp.new(/(#{dest_table})(#{self.class::OTM_RETAIN_KEY})(\d+)/)},
        :new_table_name => Proc.new {|dest_table| "#{dest_table}#{self.class::OTM_RETAIN_KEY}#{Time.now.to_i.to_s}"}
      }        
    end
  end
end
