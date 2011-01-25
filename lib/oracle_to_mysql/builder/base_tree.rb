class OracleToMysql::Builder::BaseTree
  attr_accessor :name, :mode, :trees, :args

  def initialize(*args,&block)
    options = args.extract_options!
    @args = args || []
    @name = options[:name] || nil
    @mode = options[:mode] || :linear  # can be :parallel or :linear
    @trees = []
    if block_given?
      yield self
    end      
  end
  
  def execute
    raise "child must define"
  end
end