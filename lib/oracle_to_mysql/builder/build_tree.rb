class OracleToMysql::Builder::BuildTree < OracleToMysql::Builder::BaseTree
  # breadth first style tree execution,
  # first execute builds for any otm_classes specified then
  # iterate over any sub-trees and invoke execute on them
  def execute
    case self.mode
    when :linear
      self.otm_classes.each do |klass|
        inst = klass.new
        inst.otm_execute
      end
      self.trees.each do |tree|
        tree.execute
      end      
    when :parallel
      raise "Implement"
    else
      raise "cant do stuff with #{self.mode}"
    end      
  end
  
  protected
    def otm_classes
      if @otm_classes.nil?
        @otm_classes = []
        self.args.each do |class_name|
          begin
            @otm_classes << class_name.constantize
          rescue NameError => e
            raise "Invalid class name, could not constantize #{class_name}"
          end
        end        
      end
      @otm_classes
    end
end