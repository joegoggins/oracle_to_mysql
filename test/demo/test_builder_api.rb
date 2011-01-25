require 'helper'

# test.demo is already in the load path, hence the omission of "demo/" here
# require 'ps_um_dept_tree'
# require 'job_queue_run'
require 'ps_term_tbl'
class TestBuilderApi < Test::Unit::TestCase
  context "Tree instantiation" do
    should "Be able to instantiate a build tree" do            
      @bt1 = OracleToMysql::Builder::BuildTree.new('Some::Class::Name')
      assert_kind_of(Array,@bt1.args)
      assert_equal(@bt1.name, nil)      
      assert_equal(@bt1.block_mode, nil)
      assert_equal(@bt1.args[0], 'Some::Class::Name')            
    end
  end
end
