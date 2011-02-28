module OracleToMysql
  class Command
    attr_accessor :client_class
    def info(msg)
      self.output("[info] #{msg}",:classification => :good)
    end
    def error(msg)
      self.output("[ERROR] #{msg}", :classification => :bad)
      raise OracleToMysql::CommandError.new("#{self.client_class.to_s}#otm_execute died on command=#{self.class.to_s}")
    end
    def warn(msg)
      self.output("[WARN] #{msg}", :classification => :good_w_warning)
    end

    def started(msg='')
      self.output("[started t=#{self.client_class.otm_time_elapsed_since_otm_timestamp}]#{msg}", :classification => :good_started)
    end
    
    def finished(msg='')
      self.output("[finished t=#{self.client_class.otm_time_elapsed_since_otm_timestamp}]#{msg}",:classification => :good_started)
    end

    # USE THE ones above if possible, it makes the output more uniform and easier to read/parse
    # Stuff funnels to here, which propogates up to the client class
    def output(msg, options={})
      self.client_class.otm_output("[#{self.class.to_s}]#{msg}",options)
    end
       
    # Client classes call this method     
    def execute
      self.started
      self.execute_internal
      self.finished
    end
    
    # Commands should override this if they use temp files that need to be cleaned up
    # The cleanup_temp_files_and_tables command reflects on all commands to find and delete things
    # referenced in here
    def temp_file_symbols
      []
    end
    
    def execute_internal
      raise "CHILDREN MUST OVERRIDE THIS"
    end
  end
end  
