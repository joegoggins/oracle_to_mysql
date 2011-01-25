class OracleToMysql::Builder::BaseTree
  attr_accessor :name, :block_mode, :trees, :args

  def initialize(*args)
    options = args.extract_options!
    @args = args
    @name = options[:name] || nil
    @block_mode = options[:block_mode] || nil
    @trees = []
  end
  
  def execute
    raise "child must define"
  end
end