module OracleToMysql
  module OptionalOverrideInstanceMethods    
    
    # YOU WILL OFTEN WANT TO OVERRIDE THIS, 
    def otm_strategy
      if @otm_strategy.nil?
        @otm_strategy = self.class.otm_default_strategy
      end
      @otm_strategy      
    end
              
    # TO CHANGE the retain options, override this method
    #    
    def otm_retain_options
      if @otm_retain_options.nil?
        @otm_retain_options = self.class.otm_default_retain_options
      end
      @otm_retain_options
    end
    
    # This results in mysql queries executing afterwords that optimize the table
    # and get it set for prime time usage...
    #
    def otm_post_mirror_options
      if @otm_post_mirror_options.nil?
        @otm_post_mirror_options = self.class.otm_default_post_mirror_options
      end
      @otm_post_mirror_options      
    end
    
    
    def otm_source_config_hash
      if self.otm_config_hash.has_key?('oracle_source')
        return otm_config_hash['oracle_source']
      else
        raise "Could not find oracle_source key in config file #{self.otm_config_file}, you should override this method"
      end
    end
    def otm_target_config_hash
      if self.otm_config_hash.has_key?('mysql_target')
        return otm_config_hash['mysql_target']
      else
        raise "Could not find mysql_target key in config file #{self.otm_config_file}, you should override this method"
      end      
    end
    
    # Override this if you have zany rules about where your config file is, there is a handy otm_config_hash method in the ApiInstanceMethods
    # you can use to get stuff outta here
    #
    def otm_config_file
      non_rails_path = File.join(Dir.pwd, 'oracle_to_mysql.yml')
      if defined?(RAILS_ROOT)
        rails_path = File.join(RAILS_ROOT,'config','database.yml')
        if rails_path
          @otm_db_config_yml_file_name = rails_path
        else
          raise "Weird, RAILS_ROOT detected but no databases.yml, something is amiss!"
        end
      elsif File.exists?(non_rails_path)
        @otm_db_config_yml_file_name = non_rails_path
      else
        raise "ERROR: No otm config file found"
      end
    end  
    
    # This is the table name that is created first on the server for the :atomic_rename strategy
    #
    def otm_temp_target_table
      "#{self.otm_target_table}_#{self.otm_timestamp.to_i}_temp"
    end
    
    def tmp_directory
      "/tmp"  
    end                                       
  end
end
