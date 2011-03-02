require 'helper'

# test.demo is already in the load path, hence the omission of "demo/" here
# require 'ps_um_dept_tree'
# require 'job_queue_run'
require 'ps_term_tbl'
class TestOracleToMysql < Test::Unit::TestCase
  context "Test API against ps_term_tbl" do
    setup do
      @ps_term_tbl_inst = PsTermTbl.new
      # @ps_um_dept_tree = PsUmDeptTree.new
    end
    should "Assert the otm_strategy's default is an atomic_rename" do            
      assert_equal(@ps_term_tbl_inst.otm_strategy, :atomic_rename)
    end
    
    should "Assert an instance override the default" do
      @ps_term_tbl_inst.otm_set_strategy(:accumulative)
      assert_equal(@ps_term_tbl_inst.otm_strategy, :accumulative)
      @ps_term_tbl_inst.otm_set_strategy(:atomic_rename)
      assert_equal(@ps_term_tbl_inst.otm_strategy, :atomic_rename)
    end
    
    should "Have default otm_retain_options" do
      retain_options = @ps_term_tbl_inst.otm_retain_options
      assert(retain_options.has_key?(:n))
    end
    
    should "be able to invoke otm_execute" do
      @ps_term_tbl_inst.otm_execute
    end
    # 
    # should "Should be able to do a dry-run that outputs what the otm_execute will do" do
    #   assert_nothing_raised do
    #     x = PsTermTbl.otm_execute_command_names.each do |command_name|
    #       puts command_name
    #     end
    #   end
    # end        
    # 
    # should "implement the required ClientInterfaceClassMethods" do
    #   [PsTermTbl,PsUmDeptTree].each do |klass|
    #     [:otm_source_sql, :otm_target_table, :otm_target_sql].each do |meth|
    #       puts klass.send(meth)
    #     end
    #   end
    # end
    # 
    # should "have hashes for their target and source" do
    #   [PsTermTbl,PsUmDeptTree].each do |klass|
    #     [:otm_source_config_hash, :otm_target_config_hash].each do |meth|
    #       puts klass.send(meth).inspect
    #     end
    #   end      
    # end
  end
end
