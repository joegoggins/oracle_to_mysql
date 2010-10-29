module OracleToMysql
  module MustOverrideInstanceMethods    
    
    
    #### MUST BE OVERRIDEN    
    def otm_source_sql
      raise "YOU MUST OVERRIDE THIS"
    end
    def otm_target_sql
      raise "YOU MUST OVERRIDE THIS"
    end
    def otm_target_table
      raise "YOU MUST OVERRIDE THIS"
    end  
  end
end
